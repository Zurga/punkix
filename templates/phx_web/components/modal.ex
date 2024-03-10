defmodule <%= @web_namespace %>.Components.Modal do
  use <%= @web_namespace %>.Component

  slot default
  def render(assigns) do
    ~F"""
      <#slot />
    """
  end
end
