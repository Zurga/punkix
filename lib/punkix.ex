defmodule Punkix do
  defmacro __using__(_) do
    quote do
      import Punkix
      # use Punkix.Patcher
      use Patches
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
        IO.inspect("add_watchers")

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

  def inject_after_module_definition(to_inject, file_path) do
    inject_code(to_inject, file_path, fn
      {:defmodule, module_meta,
       [alias, [{{:__block__, do_block_meta, [:do]}, {:__block__, block_meta, block_ast}}]]},
      {method, _, args} ->
        {:defmodule, module_meta,
         [
           alias,
           [
             {{:__block__, do_block_meta, [:do]},
              {:__block__, block_meta, [{method, block_meta, args} | block_ast]}}
           ]
         ]}

      _, _ ->
        nil
    end)
  end

  def inject_code(content, file_path, patch_fun) do
    to_add = Sourceror.parse_string!(content)

    to_patch = File.read!(file_path)

    {_, patches} =
      to_patch
      |> Sourceror.parse_string!()
      |> Macro.postwalk([], fn quoted, patches ->
        if replacement = patch_fun.(quoted, to_add) do
          range = Sourceror.get_range(quoted)
          patch = %{range: range, change: replacement |> Sourceror.to_string()}
          {quoted, [patch | patches]}
        else
          {quoted, patches}
        end
      end)

    patched = Sourceror.patch_string(to_patch, patches)
    File.write(file_path, patched)
  end

  def maybe_merge_blocks(tuple, {:__block__, meta, other_content}) when is_tuple(tuple) do
    {:__block__, meta, [tuple | other_content]}
  end

  def maybe_merge_blocks({:__block__, meta, other_content}, other) when is_tuple(other) do
    {:__block__, meta, other_content ++ [other]}
  end

  def maybe_merge_blocks({:__block__, meta, content}, list) when is_list(list) do
    {:__block__, meta, content ++ list}
  end

  def maybe_merge_blocks(
        {:__block__, meta, content} = block,
        {:__block__, _meta, other_content} = other_block
      ) do
    {:__block__, meta, content ++ other_content}
  end
end
