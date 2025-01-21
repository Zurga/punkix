defmodule Punkix.EventRouter.EventHandler do
  require Logger
  use Pathex
  use GenServer
  import Punkix.Repo, only: [get_schema: 1]
  @events ~w/inserted updated deleted/a

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(state) do
    # Enum.each(state[:watchers], &EctoWatch.subscribe/1)

    {:ok,
     %{
       config: %{
         repo: state[:repo],
         cache_name: state[:cache_name]
       },
       subscriptions:
         for schema <- state[:watchers], into: %{} do
           {schema, %{inserted: %{}, updated: %{}, deleted: %{}}}
         end
     }}
  end

  def subscribe(
        watcher_identifier,
        id \\ nil,
        opts \\ [preloads: [], get_fun: nil]
      ) do
    message = {:subscribe, self(), watcher_identifier, id, opts}
    Logger.debug("subscribe: #{inspect(message)}")
    GenServer.cast(__MODULE__, message)
  end

  def unsubscribe(schema) do
    GenServer.cast(__MODULE__, {:unsubscribe, self(), schema})
  end

  def handle_cast({:subscribe, pid, watcher_identifier, opts, _opts}, state) when is_list(opts),
    do: do_subscribe(pid, watcher_identifier, nil, opts, state)

  def handle_cast({:subscribe, pid, watcher_identifier, id, opts}, state),
    do: do_subscribe(pid, watcher_identifier, id, opts, state)

  defp do_subscribe(pid, watcher_identifier, id, opts, state) do
    schema_events =
      case watcher_identifier do
        {schema, :all} -> Enum.map(@events, &{schema, &1})
        label when is_atom(label) -> [label]
        _ -> List.wrap(watcher_identifier)
      end

    get_fun =
      case schema_events do
        [{schema, _event} | _] when is_atom(schema) ->
          opts[:get_fun] || repo_get(schema, state.config.repo)

        _ ->
          opts[:get_fun]
      end

    default = [{pid, get_fun}]

    subscriptions =
      Enum.reduce(schema_events, state.subscriptions, fn event, subscriptions ->
        path = subscribers_path(event, id) ~> path(opts[:preloads])

        if not any_subscribers?(Pathex.get(subscriptions, path)) do
          EctoWatch.subscribe(event, id)
          Pathex.force_set!(subscriptions, path, default)
        else
          Pathex.over!(subscriptions, path, &(default ++ &1))
        end
      end)

    {:noreply, %{state | subscriptions: subscriptions}}
  end

  def handle_cast({:unsubscribe, pid, value}, state) do
    schema = get_schema(value)

    is_pid = fn
      {^pid, _} -> true
      _ -> false
    end

    subscriptions =
      Enum.reduce(@events, state.subscriptions, fn event, acc ->
        path = subscribers_path(event, value.id)

        preloads =
          acc
          |> Pathex.get(path)
          |> Enum.reduce_while(nil, fn {preloads, pids}, acc ->
            (Enum.find(pids, &is_pid.(&1)) && {:halt, preloads}) || {:cont, acc}
          end)

        pids_path = path ~> path(preloads)

        if not any_subscribers?(Pathex.get(acc, pids_path)) do
          EctoWatch.unsubscribe({schema, event})
        end

        Pathex.over!(acc, pids_path, fn pids -> Enum.reject(pids, &is_pid.(&1)) end)
      end)

    {:noreply, %{state | subscriptions: subscriptions}}
  end

  def handle_info({{schema, event} = schema_event, id} = message, state) do
    Logger.debug("EventHandler #{inspect(message)}")

    id = Map.get(id || %{}, :id)

    path = subscribers_path(schema_event, id)
    receivers = Pathex.get(state.subscriptions, path)

    if any_subscribers?(receivers) do
      {:ok, key} =
        case event do
          :deleted ->
            update_cache(schema_event, id, nil, state.config)

          _ ->
            preloads = get_all_preloads(receivers)
            update_cache(schema_event, id, preloads, state.config)
        end

      broadcast(receivers, schema_event, key, state.config)
    end

    {:noreply, state}
  end

  defp update_cache({schema, :deleted}, id, _, config) do
    Cachex.del(config.cache_name, {schema, id})
    {:ok, {schema, id}}
  end

  defp update_cache({schema, _event}, id, preloads, config) do
    key = {schema, id}
    record = config.repo.get!(schema, id) |> config.repo.preload(preloads)
    {:ok, true} = Cachex.put(config.cache_name, key, record)
    {:ok, key}
  end

  defp broadcast(receivers, {_, event} = schema_event, {_, id} = key, config) do
    for {preloads, pids_get_funs} <- receivers,
        {pid, get_fun} <- pids_get_funs do
      fun =
        case event do
          :deleted ->
            fn -> {:ok, id} end

          _ ->
            fn ->
              {_, value} =
                Cachex.fetch(config.cache_name, key, fn {_schema, id} ->
                  {:commit, get_fun.(id)}
                end)

              {:ok, set_preloads(value, preloads)}
            end
        end

      send(pid, {schema_event, fun})
    end
  end

  defp get_all_preloads(subscriptions) do
    subscriptions
    |> Enum.reduce([], fn {preloads, _}, acc ->
      DeepMerge.deep_merge(acc, preloads || [])
    end)
    |> IO.inspect(label: :all_preloads)
  end

  defp repo_get(schema, repo) do
    fn %{id: id} = value_info ->
      repo.get(schema, id)
    end
  end

  defp any_subscribers?(nil) do
    false
  end

  defp any_subscribers?(subscriptions) do
    subscriptions
    |> Enum.map(&elem(&1, 1))
    |> Enum.any?()
  end

  defp subscribers_path({schema, :inserted = event}, _id) do
    path(schema / event)
  end

  defp subscribers_path({schema, event}, id) do
    path(schema / event / id)
  end

  defp subscribers_path(label, id) do
    path(label / id)
  end

  defp set_preloads(value, preloads) do
    Logger.debug("Setting preloads: #{inspect(value)}, #{inspect(preloads)}")

    # preloads =
    #   Ecto.Repo.Preloader.normalize(preloads, [], preloads)

    value = do_set_preloads(value, preloads || [])
    Logger.debug("Set preloads: #{inspect(value)}, #{inspect(preloads)}")
    value
  end

  # defp do_set_preloads(value, preload) when is_atom(preload) do
  #   do_set_preloads(value, [{preload, []}])
  # end

  defp do_set_preloads(value, []) do
    assocs = get_schema(value).__schema__(:associations)
    Ecto.reset_fields(value, assocs)
  end

  defp do_set_preloads(value, preloads) do
    assocs = get_schema(value).__schema__(:associations)

    for {key, {_, _, nested_preloads}} <- preloads, reduce: value do
      acc ->
        if key in assocs do
          Map.update!(acc, key, &do_set_preloads(&1, nested_preloads))
        else
          Ecto.reset_fields(acc, [key])
        end
    end
  end
end
