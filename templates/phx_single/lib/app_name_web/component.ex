defmodule <%= @web_namespace %>.Component do
  defmacro __using__(_) do
    quote do
      use Surface.Component

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_csrf_token: 0, view_module: 1, view_template: 1]

      unquote(<%= @web_namespace %>.html_helpers())
    end
  end
end
