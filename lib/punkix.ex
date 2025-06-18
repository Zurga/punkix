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

      def eval_file(source, binding, other) do
        {fun, _} = Mix.Tasks.Format.formatter_for_file(source)

        source
        |> EEx.eval_file(binding)
        |> fun.()
      end

      def add_watchers(context) do
        application_path = Mix.Phoenix.context_lib_path(context.context_app, "application.ex")

        with {:ok, application_source} <- File.read(application_path) do
          patched_source =
            application_source
            |> then(fn source ->
              split = String.split(source, "\n")

              first_use =
                Enum.find_index(split, &(String.trim_leading(&1) |> String.starts_with?("use")))

              split
              |> List.insert_at(
                first_use,
                "alias #{inspect(context.schema.module)}"
              )
              |> Enum.join("\n")
            end)
            |> Sourceror.parse_string!()
            |> Macro.postwalk(fn
              {{bl, watch_meta, [:watchers]}, args} ->
                {{bl, watch_meta, [:watchers]}, add_watcher(context.schema.alias, args)}

              q ->
                q
            end)
            |> Sourceror.to_string()

          File.write(application_path, patched_source)
        end

        context
      end

      defp add_watcher(name, args) do
        {:|>, [],
         [
           args,
           {{:., [trailing_comments: [], line: 5, column: 15],
             [
               {:__aliases__,
                [
                  trailing_comments: [],
                  leading_comments: [],
                  last: [line: 5, column: 4],
                  line: 5,
                  column: 4
                ], [:EctoSync]},
               :watchers
             ]},
            [
              trailing_comments: [],
              leading_comments: [],
              closing: [line: 5, column: 31],
              line: 5,
              column: 16
            ],
            [
              {:__aliases__,
               [
                 trailing_comments: [],
                 leading_comments: [],
                 last: [line: 5, column: 27],
                 line: 5,
                 column: 27
               ], [:"#{inspect(name)}"]}
            ]}
         ]}
      end
    end
  end

  defdelegate spec_alias(alias), to: Punkix.Context
end
