Mix.shell(Mix.Shell.Process)

defmodule Punkix.GenSchemaTest do
  use ExUnit.Case, async: true
  import MixHelper

  @tag timeout: :infinity
  test "new_schema" do
    Application.put_env(:punkix, :dep, ~s[path: "../../../"])

    in_tmp("test", fn project_path, project_name ->
      assert {_, 0} =
               mix_cmd(
                 project_path,
                 "punkix.gen.schema",
                 "Article articles name:string description:string"
               )

      schemas_path = Path.join(project_path, "lib/#{project_name}/schemas")

      assert_file(Path.join(schemas_path, "article.ex"), "typed_schema")

      assert {_, 0} = mix_cmd(project_path, "test")
    end)
  end

  @tag timeout: :infinity
  test "new_schema with belongs_to assocs" do
    Application.put_env(:punkix, :dep, ~s[path: "../../../"])

    in_tmp("test", fn project_path, project_name ->
      app_name = Phoenix.Naming.camelize(project_name)

      assert {_, 0} =
               mix_cmd(
                 project_path,
                 "punkix.gen.schema",
                 "Person persons name:string description:string articles:references:articles,reverse:Article,foreign_key:writer_id"
               )

      assert {_, 0} =
               mix_cmd(
                 project_path,
                 "punkix.gen.schema",
                 "Article articles name:string description:string writer_id:references:persons,reverse:Person,required:true"
               )

      schemas_path = Path.join(project_path, "lib/#{project_name}/schemas")
      assert_file(Path.join(schemas_path, "person.ex"), "has_many :articles, Article")
      assert_file(Path.join(schemas_path, "article.ex"), "belongs_to :writer, Person")

      [persons_migration, articles_migration] =
        Path.wildcard(project_path <> "/priv/repo/migrations/*.exs")
        |> Enum.sort()
        |> IO.inspect()

      assert_file(persons_migration, """
      defmodule #{app_name}.Repo.Migrations.CreatePersons do
        use Ecto.Migration

        def change do
          create table(:persons) do
            add :name, :string
            add :description, :string

            timestamps(type: :utc_datetime)
          end

        end
      end
      """)

      assert_file(articles_migration, """
      defmodule #{app_name}.Repo.Migrations.CreateArticles do
        use Ecto.Migration

        def change do
          create table(:articles) do
            add :name, :string
            add :description, :string
            add :writer_id, references("persons", on_delete: :nothing), null: false

            timestamps(type: :utc_datetime)
          end

          create index("articles", [:writer_id])
        end
      end
      """)

      assert {_, 0} = mix_cmd(project_path, "test")
    end)
  end
end
