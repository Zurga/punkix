defmodule Punkix.SchemaTest do
  use ExUnit.Case

  use Punkix
  use Punkix.Patches.Schema
  alias Punkix.Schema

  alias Mix.Tasks.Phx.Gen

  setup do
    [
      schema:
        Gen.Schema.build(
          ~w"Article articles name:string description:string category_id:references:article_categories,type:belongs_to,required:true,reverse:Article.Category.articles tags:references:tags,through:Tags,type:many_to_many,reverse:Article.Tag.articles labels:references:labels,type:has_many,reverse:Label",
          []
        )
        |> Schema.set_assocs()
    ]
  end

  describe "assoc_aliases" do
    test "assoc aliases", %{schema: schema} do
      assert Schema.assoc_aliases(schema) == "Article.Category, Article.Tag, Tags, Label"
    end
  end

  describe "set_assocs" do
    test "setup correct assocs", %{schema: schema} do
      schema
    end
  end

  describe "optional fields" do
    test "optional fields", %{schema: schema} do
      assert Schema.optional_fields(schema) == ~w/tags labels/a
    end
  end
end
