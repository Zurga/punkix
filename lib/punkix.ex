defmodule Punkix do
  defmacro __using__(_) do
    quote do
      use Punkix.Patcher
      wrap(Mix.Phoenix, :generator_paths, 0, :add_punkix)

      def add_punkix(paths) do
        List.insert_at(paths, 1, :punkix)
      end
    end
  end

  defdelegate spec_alias(alias), to: Punkix.Context
end
