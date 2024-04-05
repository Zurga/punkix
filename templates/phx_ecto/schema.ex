defmodule <%= @app_module %>.Schema do
  defmacro __using__(_) do
    quote do
      use TypedEctoSchema
    end
  end
end
