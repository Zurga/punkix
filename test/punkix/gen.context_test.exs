Mix.shell(Mix.Shell.Process)

defmodule Punkix.GenContextTest do
  use ExUnit.Case, async: true
  import MixHelper

  @tag timeout: :infinity
  test "new_context with belongs_to assocs" do
    Application.put_env(:punkix, :dep, ~s[path: "../../../"])

    in_tmp("test", fn project_path, project_name ->
      assert {_, 0} =
               mix_cmd(
                 project_path,
                 "punkix.gen.context",
                 "Persons Person persons name:string description:string articles:references:articles,type:has_many,reverse:Articles.Article.writer,foreign_key:writer_id"
               )

      Process.sleep(1000)

      assert {_, 0} =
               mix_cmd(
                 project_path,
                 "punkix.gen.context",
                 "Articles Article articles name:string description:string writer_id:references:persons,type:belongs_to,reverse:Persons.Person.articles,required:true comments:references:comments,type:has_many,reverse:Articles.Comment.article"
               )

      Process.sleep(1000)

      assert {_, 0} =
               mix_cmd(
                 project_path,
                 "punkix.gen.context",
                 "Articles Comment comments text:string writer_id:references:persons,type:belongs_to,reverse:Persons.Person.articles,required:true article_id:references:articles,type:belongs_to,reverse:Articles.Article.comments,required:true"
               )

      schemas_path = Path.join(project_path, "lib/#{project_name}/schemas")
      contexts_path = Path.join(project_path, "lib/#{project_name}")

      assert_file(
        Path.join([schemas_path, "articles", "article.ex"]),
        "belongs_to :writer, Person"
      )

      context_file = Path.join([contexts_path, "articles.ex"])

      assert_file(context_file, "Repo.with_assocs(articles: article_attrs[:writer])")

      assert_file(context_file, "optional(:comments) => [Comment.t()]")

      assert_file(
        Path.join([schemas_path, "persons", "person.ex"]),
        "has_many :articles, Article"
      )

      assert {_, 0} = mix_cmd(project_path, "test")
    end)
  end
end
