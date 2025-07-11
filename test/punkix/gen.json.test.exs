Mix.shell(Mix.Shell.Process)

defmodule Punkix.Gen.JSONTest do
  use ExUnit.Case, async: true
  import MixHelper
  import Punkix.Test.Support.Gen.Web

  @tag timeout: :infinity
  test "new_live" do
    Application.put_env(:punkix, :dep, ~s[path: "../../../"])

    in_tmp("test", fn project_path, project_name ->
      gen_web(:live, project_path, project_name)

      schemas_path = Path.join(project_path, "lib/#{project_name}/schemas/articles/")
      app_name = Phoenix.Naming.camelize(project_name)
      router_path = Path.join([project_path, "lib", "#{project_name}_web", "router.ex"])

      router_file =
        File.read!(router_path)
        |> String.split("\n")
        |> Enum.reduce("", fn line, acc ->
          # FIXME live sessions here
          line =
            if String.contains?(line, "# TODO add your routes here") do
              [person_schema, article_schema, comment_schema]
              |> Enum.map(fn args_string ->
                String.split(args_string, " ")
                |> Mix.Tasks.Phx.Gen.Context.build([])
                |> then(&(elem(&1, 1) |> Map.put(:web_namespace, app_name <> "Web")))
                |> Punkix.Schema.set_assocs()
                |> Mix.Tasks.Punkix.Gen.Live.live_route_instructions()
              end)
              |> Enum.join("\n")
            else
              line
            end

          acc <> "\n " <> line
        end)

      File.write(router_path, router_file)

      assert_file(Path.join(schemas_path, "article.ex"), "typed_schema")
      assert_file(Path.join(project_path, "lib/#{project_name}_web/live/article_live/index.ex"))

      assert_file(
        Path.join(project_path, "lib/#{project_name}_web/live/article_live/index.sface")
      )

      assert_file(Path.join(project_path, "lib/#{project_name}_web/live/article_live/show.ex"))

      assert_file(Path.join(project_path, "lib/#{project_name}_web/live/article_live/show.sface"))

      assert_file(
        Path.join(project_path, "lib/#{project_name}_web/live/article_live/article_component.ex")
      )

      assert_file(Path.join(project_path, "lib/#{project_name}_web/live/article_live/assigns.ex"))

      assert_file(
        Path.join(
          project_path,
          "lib/#{project_name}_web/live/article_live/article_component.ex"
        ),
        &(not (&1 =~ "Elixir"))
      )

      refute_file(Path.join(project_path, "lib/#{project_name}_web/core_components.ex"))

      assert {_, 0} = mix_cmd(project_path, "test.all")
    end)
  end

  test "router instructions" do
    app_name = "Test"

    schema =
      "Persons Person persons name:string description:string articles:references:articles,reverse:Articles.Article.writer,foreign_key:writer_id"
      |> String.split(" ")
      |> Mix.Tasks.Phx.Gen.Context.build([])
      |> then(&(elem(&1, 1) |> Map.put(:web_namespace, app_name <> "Web")))
      |> Punkix.Schema.set_assocs()

    schema
    |> Mix.Tasks.Punkix.Gen.Live.live_route_instructions()
    |> Enum.join("")
    |> IO.puts()
  end
end
