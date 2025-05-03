defmodule <%= inspect context.web_module %>.<%= inspect Module.concat(schema.web_namespace, schema.alias) %>Live.Index do
  use <%= inspect context.web_module %>.LiveView

  alias <%= inspect context.web_module %>.Components.{Table, Modal}

  alias <%= inspect context.module %>
  alias <%= inspect schema.module %>
<%= if Punkix.Context.required_assocs(schema) != [] do %>
  alias <%= inspect context.web_module %>.<%= inspect Module.concat(schema.web_namespace, schema.alias) %>Live.Assigns
<% end %>
<%= for assoc <- Punkix.Context.required_assocs(schema) do %>
  on_mount({Assigns, :<%= assoc.plural %>})
<% end %>

  @impl true
  def mount(_params, _session, socket) do
    <%= schema.collection %> = list_<%= schema.plural %>(socket)

    if connected?(socket) do
      EctoSync.subscribe({<%= inspect schema.alias %>, :inserted}, nil)
      EctoSync.subscribe(<%= schema.collection %>)
    end

    {:ok, stream(socket, :<%= schema.collection %>, <%= schema.collection %>)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    {:ok, <%= schema.singular %>} = <%= inspect context.alias %>.get_<%= schema.singular %>(id)
    socket
    |> assign(:page_title, "Edit <%= schema.human_singular %>")
    |> assign(:<%= schema.singular %>, <%= schema.singular %>)
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New <%= schema.human_singular %>")
    |> assign(:<%= schema.singular %>, %<%= inspect schema.alias %>{<%= Punkix.Schema.belongs_assocs(schema) |> Enum.map_join(", ", &"#{&1.field}: nil") %>})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing <%= schema.human_plural %>")
    |> assign(:<%= schema.singular %>, nil)
  end

  @impl true
  def handle_info({{<%= inspect(schema.alias) %>, :inserted}, <%= schema.singular %>, source}, socket) do
    {:noreply,
     socket
     |> stream_insert(:<%= schema.collection %>, <%= schema.singular %>)
     |> maybe_patch_and_flash(source, ~p"<%= schema.route_prefix %>", "<%= schema.human_singular %> created successfully")}
  end

  @impl true
  def handle_info({{<%= inspect(schema.alias) %>, :updated}, <%= schema.singular %>, source}, socket) do
    {:noreply,
     socket
     |> stream_insert(:<%= schema.collection %>, <%= schema.singular %>)
     |> maybe_patch_and_flash(source, ~p"<%= schema.route_prefix %>", "<%= schema.human_singular %> updated successfully")}
  end

  @impl true
  def handle_info({{<%= inspect(schema.alias) %>, event}, _} = sync_config, socket) do
    <%= schema.singular %> = EctoSync.sync(:cached, sync_config)

    socket = case event do
      :deleted ->  stream_delete(socket, :<%= schema.collection %>, <%= schema.singular %>)
      _ -> stream_insert(socket, :<%= schema.collection %>, <%= schema.singular %>)
    end

    {:noreply, socket}
  end

  defp list_<%= schema.plural %>(_socket) do
    <%= inspect(context.alias) %>.list_<%= schema.plural %>()
  end
end
