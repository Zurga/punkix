defmodule Punkix.Test.Support.Gen.Web do
  import MixHelper

  defmacro gen_web(command, project_path, project_name) do
    generator = "punkix.gen.#{command}"

    person_schema =
      "Persons Person persons name:string description:string articles:references:articles,reverse:Articles.Article.writer,foreign_key:writer_id"

    article_schema =
      "Articles Article articles name:string description:string writer_id:references:persons,reverse:Persons.Person.articles,required:true comments:references:comments,reverse:Articles.Comment.article"

    comment_schema =
      "Articles Comment comments text:string writer_id:references:persons,reverse:Persons.Person.articles,required:true article_id:references:articles,reverse:Articles.Article.comments,required:true"

    quote bind_quoted: [
            generator: generator,
            project_path: project_path,
            project_name: project_name,
            person_schema: person_schema,
            article_schema: article_schema,
            comment_schema: comment_schema
          ] do
      assert {_, 0} =
               mix_cmd(
                 project_path,
                 generator,
                 person_schema
               )

      Process.sleep(1000)

      assert {_, 0} =
               mix_cmd(
                 project_path,
                 generator,
                 article_schema
               )

      Process.sleep(1000)

      assert {_, 0} =
               mix_cmd(
                 project_path,
                 generator,
                 comment_schema
               )
    end
  end
end
