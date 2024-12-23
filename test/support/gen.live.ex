defmodule Punkix.Test.Support.Gen.Live do
  import MixHelper

  defmacro gen_live(project_path, project_name) do
    person_schema =
      "Persons Person persons name:string description:string articles:references:articles,reverse:Articles.Article.writer,foreign_key:writer_id"

    article_schema =
      "Articles Article articles name:string description:string writer_id:references:persons,reverse:Persons.Person.articles,required:true comments:references:comments,reverse:Articles.Comment.article"

    comment_schema =
      "Articles Comment comments text:string writer_id:references:persons,reverse:Persons.Person.articles,required:true article_id:references:articles,reverse:Articles.Article.comments,required:true"

    quote bind_quoted: [
            project_path: project_path,
            project_name: project_name,
            person_schema: person_schema,
            article_schema: article_schema,
            comment_schema: comment_schema
          ] do
      assert {_, 0} =
               mix_cmd(
                 project_path,
                 "punkix.gen.live",
                 person_schema
               )

      Process.sleep(1000)

      assert {_, 0} =
               mix_cmd(
                 project_path,
                 "punkix.gen.live",
                 article_schema
               )

      Process.sleep(1000)

      assert {_, 0} =
               mix_cmd(
                 project_path,
                 "punkix.gen.live",
                 comment_schema
               )

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
      assert_file(Path.join(project_path, "lib/#{project_name}_web/article/live/index.ex"))

      assert_file(Path.join(project_path, "lib/#{project_name}_web/article/live/index.sface"))

      assert_file(Path.join(project_path, "lib/#{project_name}_web/article/live/show.ex"))

      assert_file(Path.join(project_path, "lib/#{project_name}_web/article/live/show.sface"))

      assert_file(
        Path.join(project_path, "lib/#{project_name}_web/article/live/article_component.ex")
      )

      assert_file(
        Path.join(
          project_path,
          "lib/#{project_name}_web/article/live/article_component.ex"
        ),
        &(not (&1 =~ "Elixir"))
      )

      refute_file(Path.join(project_path, "lib/#{project_name}_web/core_components.ex"))

      assert {_, 0} = mix_cmd(project_path, "test")
    end
  end
end
