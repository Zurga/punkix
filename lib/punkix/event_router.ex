defmodule Punkix.EventRouter do
  @moduledoc """
  A Cache updater and router for events emitted when database entries are updated. Subscribers can provide a list of records that they want to receive updates on. Additionally, they can provide a function that will act as a means of authorization on the updates they should get.

  Using the subscribe function a process can subscribe to all messages for a given struct.
  """
  defstruct subscriptions: %{},
            repo: nil,
            cache_name: :dbcache,
            watchers: [],
            pub_sub: nil,
            schemas: []

  use Supervisor
  alias Punkix.EventRouter.EventHandler
  import Punkix.Repo, only: [find_preloads: 1, get_schema: 1]

  @events ~w/inserted updated deleted/a

  def all_events(list \\ [], schema, opts \\ []) when is_atom(schema) do
    list ++ Enum.map(@events, &{schema, &1, opts})
  end

  defp new(opts) do
    schemas = opts[:schemas]
    # for schema <- schemas, event <- @events do
    #   {schema, event}
    # end

    %__MODULE__{
      cache_name: opts[:cache_name],
      repo: opts[:repo],
      pub_sub: opts[:pub_sub],
      watchers: opts[:watchers],
      pub_sub: opts[:pub_sub],
      schemas: schemas
    }
  end

  def start_link(opts \\ [name: __MODULE__]) do
    state = new(opts)
    Supervisor.start_link(__MODULE__, state, name: __MODULE__)
  end

  @impl true
  def init(state) do
    children = [
      {Cachex, state.cache_name},
      {EctoWatch, [repo: state.repo, pub_sub: state.pub_sub, watchers: state.watchers]},
      {EventHandler,
       [
         name: EventHandler,
         pub_sub: state.pub_sub,
         schemas: state.schemas,
         watchers: state.watchers,
         repo: state.repo,
         cache_name: state.cache_name
       ]}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  def subscribe(value_or_values, id \\ nil, opts \\ [])

  def subscribe(%{id: id} = value, _id, opts) do
    schema = get_schema(value)

    events =
      ~w/updated deleted/a
      |> Enum.map(&{schema, &1})

    opts =
      Keyword.put_new_lazy(opts, :preloads, fn ->
        find_preloads(value)
      end)

    EventHandler.subscribe(events, id, opts)
  end

  def subscribe({schema, event} = identifier, id, opts)
      when is_atom(schema) and event in @events do
    EventHandler.subscribe(identifier, id, opts)
  end

  def subscribe(identifiers, opts, _) when is_list(identifiers) do
    Enum.each(identifiers, &subscribe(&1, nil, opts))
  end

  def subscribe(identifier, opts, _) do
    EventHandler.subscribe(identifier, nil, opts)
  end

  # def subscribe(record, preloads) do
  #   subscribe(record, preloads, nil)
  # end

  # def subscribe(record, preloads, fallback_get_fun) do
  #   EventHandler.subscribe(record, preloads, fallback_get_fun)
  # end

  def unsubscribe(record) do
    EventHandler.unsubscribe(record)
  end

  # def handle_cast({:subscribe, pid, record, preloads, fallback_get_fun}, state) do
  #   EventHandler.subscribe(
  #     pid,
  #     record,
  #     preloads,
  #   )
  # end

  def handle_info(:ecto_watch_subscribe, state) do
    IO.inspect(state, label: {__MODULE__, :ecto_watch_subscribe})

    case Application.ensure_started(:ecto_watch) do
      :ok -> Enum.each(state.watchers, &EctoWatch.subscribe/1)
      _ -> Process.send_after(self(), :ecto_watch_subscribe, 500)
    end

    {:noreply, state}
  end
end
