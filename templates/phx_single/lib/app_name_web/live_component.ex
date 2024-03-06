defmodule <%= @web_namespace %>.LiveComponent do
  defmacro __using__(_) do
    quote do
      use Surface.LiveComponent

      unquote(<%= @web_namespace %>.html_helpers())
    end
  end
end
