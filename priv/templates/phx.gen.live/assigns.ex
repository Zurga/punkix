defmodule <%= inspect context.web_module %>.<%= inspect Module.concat(schema.web_namespace, schema.alias) %>Live.Assigns do
  import Phoenix.LiveView, only: [attach_hook: 4, connected?: 1]
  import Phoenix.Component
  <%= Punkix.Context.assocs_context_aliasses(schema) %>
  <%= Punkix.Context.assocs_schema_aliasses(schema) %>

<%= for %{plural: assign} = assoc <- Punkix.Context.required_belongs_assocs(schema) do %>
  def on_mount(:<%= assign %>, _params, _session, socket) do
    <%= assign %> = <%= assoc.context %>.list_<%= assign %>()
    if connected?(socket) do
      EctoSync.subscribe({<%= assoc.schema %>, :inserted}, nil)
      EctoSync.subscribe(<%= assign %>)
    end

    socket = socket
      |> attach_hook(:<%= assign %>, :handle_info, &handle_info/2)
      |> assign(:<%= assign %>, <%= assign %>)
    {:cont, socket}
  end
<% end %>
<%= for %{plural: assign} = assoc <- Punkix.Context.required_belongs_assocs(schema) do %>
  def handle_info({{<%= assoc.schema %>, _event}, _} = sync_config, socket) do
    {:halt, update(socket, :<%= assign %>, &EctoSync.sync(&1, sync_config))}
  end
<% end %>

  def handle_info(_, socket) do
    {:cont, socket}
  end
end
