defmodule Punkix.Test.Support.Gen.Live do
  import MixHelper

  defmacro gen_live(project_path, project_name) do
    quote bind_quoted: [project_path: project_path, project_name: project_name] do
      in_tmp("test", fn project_path, project_name ->
        assert {_, 0} =
                 mix_cmd(
                   project_path,
                   "punkix.gen.live",
                   "Shop Article articles name:string description:string"
                 )

        schemas_path = Path.join(project_path, "lib/#{project_name}/schemas/shop/")

        assert_file(Path.join(schemas_path, "article.ex"), "typed_schema")
        assert_file(Path.join(project_path, "lib/#{project_name}_web/live/article_live/index.ex"))

        assert_file(
          Path.join(project_path, "lib/#{project_name}_web/live/article_live/index.sface")
        )

        assert_file(Path.join(project_path, "lib/#{project_name}_web/live/article_live/show.ex"))

        assert_file(
          Path.join(project_path, "lib/#{project_name}_web/live/article_live/show.sface")
        )

        assert_file(
          Path.join(project_path, "lib/#{project_name}_web/live/article_live/form_component.ex")
        )

        assert_file(
          Path.join(
            project_path,
            "lib/#{project_name}_web/live/article_live/form_component.ex"
          ),
          &(not (&1 =~ "Elixir"))
        )

        refute_file(Path.join(project_path, "lib/#{project_name}_web/core_components.ex"))

        router_path = Path.join([project_path, "lib", "#{project_name}_web", "router.ex"])

        router_file =
          File.read!(router_path)
          |> String.split("\n")
          |> Enum.reduce("", fn line, acc ->
            line =
              if String.contains?(line, "# TODO add your routes here") do
                """
                  live("/articles", ArticleLive.Index, :index)
                  live("/articles/new", ArticleLive.Index, :new)
                  live("/articles/:id/edit", ArticleLive.Index, :edit)

                  live("/articles/:id", ArticleLive.Show, :show)
                  live("/articles/:id/show/edit", ArticleLive.Show, :edit)
                """
              else
                line
              end

            acc <> "\n " <> line
          end)

        File.write(router_path, router_file)

        assert {_, 0} = mix_cmd(project_path, "test")
      end)
    end
  end
end
