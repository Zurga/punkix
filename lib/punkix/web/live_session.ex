defmodule Punkix.Web.LiveSession do
  defmacro __using__(opts \\ []) do
    quote do
      import Punkix.Web.LiveSession
      import Phoenix.LiveView, only: [attach_hook: 4]
      import Phoenix.Component

      @behaviour Punkix.Web.LiveSession

      def upsert(list, item) do
        [item | list]
      end
    end
  end

  @callback on_create(term(), Phoenix.Socket.t()) :: Phoenix.Socket.t()
  @callback on_update(term(), Phoenix.Socket.t()) :: Phoenix.Socket.t()
  @callback on_delete(term(), Phoenix.Socket.t()) :: Phoenix.Socket.t()

  defmacro attach_events_hook() do
    socket = Macro.var(:socket, nil)
    session = Macro.var(:session, nil)

    quote bind_quoted: [socket: socket, session: session] do
      socket =
        (session["topics"] || [])
        |> Enum.reduce(socket, fn schema, socket ->
          attach_hook(socket, schema, :handle_info, &handle_info/2)
        end)
    end
  end

  def subscribe_to_events(topics) do
    for topic <- topics do
      Phoenix.PubSub.unsubscribe(Stocker.PubSub, topic)
    end

    for topic <- topics do
      Phoenix.PubSub.subscribe(Stocker.PubSub, topic)
    end
  end
end
