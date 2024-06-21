defmodule <%= @web_namespace %>.IndexLive do
  use <%= @web_namespace %>.LiveView

  def render(assigns) do
    ~F"""
    Hello!
    """
  end
end
