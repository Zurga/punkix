defmodule Punkix.Web.InteractionRecorderTest do
  use Surface.LiveView

  def render(assigns) do
    ~F"""
    <button>Click me!</button>
    """
  end
end
