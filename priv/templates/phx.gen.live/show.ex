defmodule <%= inspect context.web_module %>.<%= inspect Module.concat(schema.web_namespace, schema.alias) %>Live.Show do
  use <%= inspect context.web_module %>.LiveView

  alias <%= inspect context.module %>
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

  @impl true
  def handle_info({<%= inspect context.web_module %>.<%= inspect Module.concat(schema.web_namespace, schema.alias) %>Live.<%= inspect(schema.alias) %>Component, {:updated, <%= schema.singular %>}}, socket) do
    {:noreply, 
      socket
      |> put_flash(:info, "<%= schema.human_singular %> updated successfully")
      |> assign(:<%= schema.singular %>, <%= schema.singular %>)}
  end
end
