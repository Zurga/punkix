defmodule <%= inspect context.web_module %>.<%= inspect Module.concat(schema.web_namespace, schema.alias) %>Live.Show do
  use <%= inspect context.web_module %>.LiveView

  alias <%= inspect context.module %>
  alias <%= inspect schema.module %>
  alias <%= inspect context.web_module %>.<%= inspect Module.concat(schema.web_namespace, schema.alias) %>Live.<%= inspect(schema.alias) %>Component
  alias <%= inspect context.web_module %>.Components.Modal

<%= if schema.assocs != [] do %>
  alias <%= inspect context.web_module %>.<%= inspect Module.concat(schema.web_namespace, schema.alias) %>Live.Assigns
<% end %>
<%= for assoc <- schema.assocs do %>
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

  defp page_title(:show), do: gettext("Show <%= schema.human_singular %>")
  defp page_title(:edit), do: gettext("Edit <%= schema.human_singular %>")

  @impl true
  def handle_info({%<%= inspect(schema.alias) %>{} = <%= schema.singular %>, :updated}, socket) do
    {:noreply,
     socket
     |> put_flash(~p"<%= schema.route_prefix %>", gettext("<%= schema.human_singular %> updated successfully"))
     |> assign(:<%= schema.singular%>, <%= schema.singular %>)}
  end

  @impl true
  def handle_info({EctoSync, {<%= inspect(schema.alias) %>, _event, _} = sync_config}, socket) do
    {:noreply, update(socket, :<%= schema.singular %>, &EctoSync.sync(&1, sync_config))}
  end
end
