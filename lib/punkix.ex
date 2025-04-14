defmodule Punkix do
  defmacro __using__(_) do
    quote do
      use Punkix.Patcher
      patch(Mix.Phoenix)
      wrap(Mix.Phoenix, :generator_paths, 0, :add_punkix)

      def add_punkix(paths) do
        List.insert_at(paths, 1, :punkix)
      end

      patch(EEx)
      replace(EEx, :eval_file, 3, :eval_file)

      def eval_file(source, binding, _) do
        unformatted = EEx.eval_file(source, binding)

        if String.ends_with?(source, ".ex") do
          Code.format_string!(unformatted)
        else
          unformatted
        end
      end
    end
  end

  defdelegate spec_alias(alias), to: Punkix.Context
end
