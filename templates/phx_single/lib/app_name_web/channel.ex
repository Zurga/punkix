defmodule <%= @web_namespace %>.Channel do
  defmacro __using__(_) do
    quote do
      use Phoenix.Channel
    end
  end
end
