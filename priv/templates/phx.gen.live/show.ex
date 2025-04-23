defmodule <%= inspect context.web_module %>.<%= inspect Module.concat(schema.web_namespace, schema.alias) %>Live.Show do
  use <%= inspect context.web_module %>.LiveView

  alias <%= inspect context.module %>
  alias <%= inspect schema.module %>
  alias <%= inspect context.web_module %>.Components.Modal

<%= if Punkix.Context.required_assocs(schema) != [] do %>
  alias <%= inspect context.web_module %>.<%= inspect Module.concat(schema.web_namespace, schema.alias) %>Live.Assigns
<% end %>
<%= for assoc <- Punkix.Context.required_assocs(schema) do %>
  on_mount({Assigns, :<%= assoc.plural %>})
<% end %>

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:ok, <%= schema.singular %>} = <%= inspect context.alias %>.get_<%= schema.singular %>(id)    

    if connected?(socket) do
      EctoSync.subscribe(<%= schema.singular %>)
    end

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:<%= schema.singular %>, <%= schema.singular %>)}
  end

  defp page_title(:show), do: "Show <%= schema.human_singular %>"
  defp page_title(:edit), do: "Edit <%= schema.human_singular %>"

  @impl true
  def handle_info({{<%= inspect(schema.alias) %>, :updated}, <%= schema.singular %>, _source}, socket) do
    {:noreply, 
      socket
      |> put_flash(:info, "<%= schema.human_singular %> updated successfully")
      |> assign(:<%= schema.singular %>, <%= schema.singular %>)}
  end

  @impl true
  def handle_info(%{schema: <%= inspect(schema.alias) %>, event: event} = sync_config, socket) do
    {:noreply, update(socket, :<%= schema.singular %>, &EctoSync.sync(&1, sync_config))}
  end
end
