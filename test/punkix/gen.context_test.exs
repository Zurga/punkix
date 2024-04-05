Mix.shell(Mix.Shell.Process)

defmodule Punkix.GenContextTest do
  use ExUnit.Case, async: true
  import MixHelper

  @tag timeout: :infinity
  test "new_context" do
    Application.put_env(:punkix, :dep, ~s[path: "../../../"])

    in_tmp("test", fn project_path, project_name ->
      Mix.Tasks.Punkix.run(~w"--no-install #{project_path}")

      put_cache(project_path)
      assert {_, 0} = mix_cmd(project_path, "deps.get")

      assert {_, 0} =
               mix_cmd(
                 project_path,
                 "punkix.gen.context",
                 "Shop ArticleCategory article_categories name:string"
               )

      assert {_, 0} =
               mix_cmd(
                 project_path,
                 "punkix.gen.context",
                 "Shop Article articles name:string description:string category:references:article_categories"
               )

      assert_file(
        Path.join(project_path, "lib/#{project_name}/schemas/shop/article.ex"),
        "Schemas.Shop.Article"
      )

      assert_file(Path.join(project_path, "lib/#{project_name}/shop.ex"))

      assert {_, 0} = mix_cmd(project_path, "test")
    end)
  end
end
