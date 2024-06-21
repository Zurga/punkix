defmodule <%= @web_namespace %>.LiveView do
  @moduledoc false
  defmacro __using__(_) do
    quote do
      use Surface.LiveView,
        layout: {<%= @web_namespace %>.Layouts, :app}

      unquote(<%= @web_namespace %>.html_helpers())
    end
  end
end
