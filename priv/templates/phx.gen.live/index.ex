defmodule <%= inspect context.web_module %>.<%= inspect Module.concat(schema.web_namespace, schema.alias) %>Live.Index do
  use <%= inspect context.web_module %>.LiveView

  alias <%= inspect context.web_module %>.Components.{Table, Modal}
  alias <%= inspect context.web_module %>.Components.Table.Column

  alias <%= inspect context.module %>
  alias <%= inspect schema.module %>
  alias Surface.Components.{Link, LivePatch}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :<%= schema.collection %>, <%= inspect context.alias %>.list_<%= schema.plural %>())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    {:ok, <%= schema.singular %>}  = <%= inspect context.alias %>.get_<%= schema.singular %>(id)
    socket
    |> assign(:page_title, "Edit <%= schema.human_singular %>")
    |> assign(:<%= schema.singular %>, <%= schema.singular %>)
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New <%= schema.human_singular %>")
    |> assign(:<%= schema.singular %>, %<%= inspect schema.alias %>{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing <%= schema.human_plural %>")
    |> assign(:<%= schema.singular %>, nil)
  end

  @impl true
  def handle_info({<%= inspect context.web_module %>.<%= inspect Module.concat(schema.web_namespace, schema.alias) %>Live.FormComponent, {:saved, <%= schema.singular %>}}, socket) do
    {:noreply, stream_insert(socket, :<%= schema.collection %>, <%= schema.singular %>)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    {:ok, <%= schema.singular %>} = <%= inspect context.alias %>.delete_<%= schema.singular %>(id)

    {:noreply, stream_delete(socket, :<%= schema.collection %>, <%= schema.singular %>)}
  end
end
