defmodule <%= inspect context.web_module %>.<%= inspect Module.concat(schema.web_namespace, schema.alias) %>Live.LiveSession do
  use Punkix.Web.LiveSession
  <%= Punkix.Context.assocs_context_aliasses(schema) %>
  <%= Punkix.Context.assocs_schema_aliasses(schema) %>

  def on_mount(:default, _params, session, socket) do
    # attach_events_hook()
    socket =
      (session["handle_events"] || [])
      |> Enum.reduce(socket, fn schema, socket ->
        attach_hook(socket, schema, :handle_info, &handle_info/2)
      end)
    # TODO add_topic

    # socket = socket
    # |> LiveSession.topics_as_assigns(session)
    {:cont, socket<%= for assoc <- Punkix.Context.required_assocs(schema) do %> 
      |> assign_<%= assoc.plural %>()<% end %>}
  end

  # TODO add all assocs that are named in the topics, use function
  # defp load_topic("customers", params, session, socket) do
  #   Customers.list_customers()
  # end

  def handle_info(message, socket) do
    {:noreply, socket}
  end

<%= for assoc <- Punkix.Context.required_assocs(schema) do %>
  def assign_<%= assoc.plural %>(socket) do
    <%= assoc.plural %> = <%= assoc.context %>.list_<%= assoc.plural %>()
    assign(socket, <%= assoc.plural %>: <%= assoc.plural %>)
  end <% end %>
<%= for assoc <- Punkix.Context.required_assocs(schema) do %>
  @impl true
  def on_create(%<%= assoc.schema %>{} = <%= String.downcase(assoc.schema) %>, socket) do
    update(socket, :<%= assoc.field %>, &upsert(&1, <%= String.downcase(assoc.schema) %>))
  end

  @impl true
  def on_create(%<%= assoc.schema %>{} = <%= String.downcase(assoc.schema) %>, socket) do
    update(socket, :<%= assoc.field %>, &upsert(&1, <%= String.downcase(assoc.schema) %>))
  end

  @impl true
  def on_create(%<%= assoc.schema %>{} = <%= String.downcase(assoc.schema) %>, socket) do
    update(socket, :<%= assoc.field %>, &upsert(&1, <%= String.downcase(assoc.schema) %>))
  end<% end %>
end
