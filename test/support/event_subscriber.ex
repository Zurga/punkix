defmodule EventSubscriber do
  use GenServer
  alias Punkix.EventRouter
  import Punkix.Repo, only: [get_schema: 1]

  def start_link(_) do
    GenServer.start_link(__MODULE__, [])
  end

  @impl true
  def init(_items) do
    {:ok, %{}}
  end

  def subscribe(pid, schema, opts \\ []) do
    GenServer.cast(pid, {:subscribe, schema, opts})
  end

  def unsubscribe(pid, schema) do
    GenServer.cast(pid, {:unsubscribe, schema})
  end

  def events(pid, schema) do
    GenServer.call(pid, {:events, schema})
  end

  @impl true
  def handle_cast({:subscribe, schema, opts}, state) do
    EventRouter.subscribe(schema, opts)
    {:noreply, state}
  end

  @impl true
  def handle_cast({:unsubscribe, schema}, state) do
    EventRouter.unsubscribe(schema)
    {:noreply, state}
  end

  @impl true
  def handle_call({:events, schema}, _from, state) do
    {:reply, Map.get(state, get_schema(schema)), state}
  end

  @impl true
  def handle_info({{schema, event}, get_fun}, state) do
    {:ok, value} = get_fun.()
    default = {event, value}
    {:noreply, Map.update(state, schema, [default], &[default | &1])}
  end
end
