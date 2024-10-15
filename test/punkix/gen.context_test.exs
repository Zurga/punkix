Mix.shell(Mix.Shell.Process)

defmodule Punkix.GenContextTest do
  use ExUnit.Case, async: true
  import MixHelper

  @tag timeout: :infinity
  test "new_context" do
    Application.put_env(:punkix, :dep, ~s[path: "../../../"])

    in_tmp("test", fn project_path, project_name ->
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

  @tag timeout: :infinity
  test "new_context with belongs_to assocs" do
    Application.put_env(:punkix, :dep, ~s[path: "../../../"])

    in_tmp("test", fn project_path, project_name ->
      assert {_, 0} =
               mix_cmd(
                 project_path,
                 "punkix.gen.context",
                 "Persons Person persons name:string description:string articles:references:articles,schema:Articles.Article.writer,foreign_key:writer_id"
               )

      assert {_, 0} =
               mix_cmd(
                 project_path,
                 "punkix.gen.context",
                 "Articles Article articles name:string description:string writer_id:references:persons,schema:Persons.Person.articles,required:true"
               )

      schemas_path = Path.join(project_path, "lib/#{project_name}/schemas")
      contexts_path = Path.join(project_path, "lib/#{project_name}")

      assert_file(
        Path.join([schemas_path, "articles", "article.ex"]),
        "belongs_to :writer, Person"
      )

      assert_file(
        Path.join([contexts_path, "articles.ex"]),
        "Repo.with_assocs(articles: writer)"
      )

      assert_file(
        Path.join([schemas_path, "persons", "person.ex"]),
        "has_many :articles, Article"
      )

      assert {_, 0} = mix_cmd(project_path, "test")
    end)
  end
end
