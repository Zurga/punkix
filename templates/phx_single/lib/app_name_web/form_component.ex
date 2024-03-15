defmodule <%= @web_namespace %>.FormComponent do
  defmacro __using__(_) do
    quote do
      use Surface.LiveComponent
      alias Surface.Components.Form
      alias Surface.Components.Form.{Field}
      import unquote(__MODULE__)

      unquote(<%= @web_namespace %>.html_helpers())
    end
  end

  import Ecto.Changeset

#   def autosave(%{assigns: %{action: :new}} = socket, params) do
#     changeset = do_change(params, socket)

#     assign(socket, changeset: changeset, saved: false)
#   end

#   def autosave(%{assigns: %{action: action}} = socket, params) do
#     changeset = do_change(params, socket)

#     socket
#     |> assign(changeset: changeset)
#     |> save(socket.assigns.action, params)
#     |> maybe_put_changeset(socket)
#   end

#   defp maybe_put_changeset(result, socket) do
#     case result do
#       {:ok, socket} ->
#         assign(socket, saved: true)

#       {:error, changeset} ->
#         assign(socket, changeset: changeset, saved: false)
#     end
#   end

#   defp do_change(params, socket) do
#     change(params, socket)
#     |> Map.put(:action, :validate)
#   end

#   @impl true
#   def handle_event("unsaved", _, socket),
#     do: {:noreply, assign(socket, saved: false)}
end
