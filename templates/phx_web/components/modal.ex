defmodule <%= @web_namespace %>.Components.Modal do
  use <%= @web_namespace %>.Component

  slot default
  def render(assigns) do
    ~F"""
      <div class="modal">
        <#slot />
      </div>
    """
  end
end
