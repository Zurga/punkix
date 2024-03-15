defmodule <%= inspect context.web_module %>.<%= inspect Module.concat(schema.web_namespace, schema.alias) %>Live.Show do
  use <%= inspect context.web_module %>.LiveView

  alias <%= inspect context.module %>
  alias Surface.Components.Link
  alias <%= inspect context.web_module %>.Components.Modal

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:ok, <%= schema.singular %>} = <%= inspect context.alias %>.get_<%= schema.singular %>(id)    

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:<%= schema.singular %>, <%= schema.singular %>)}
  end

  defp page_title(:show), do: "Show <%= schema.human_singular %>"
  defp page_title(:edit), do: "Edit <%= schema.human_singular %>"
end
