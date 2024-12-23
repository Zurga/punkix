defmodule Punkix.ContextTest do
  use ExUnit.Case
  use Punkix
  use Punkix.Patches.Schema

  alias Punkix.Context
  alias Mix.Tasks.Phx.Gen

  setup do
    [
      schema:
        Gen.Schema.build(
          ~w"Article articles name:string description:string category_id:references:article_categories,required:true,reverse:Article.Category.articles",
          []
        )
        |> Punkix.Schema.set_assocs()
    ]
  end

  describe "context_fun_spec/1" do
    test "with nullable" do
      schema =
        Gen.Schema.build(~w/Shop.Article articles name:string/, [])

      assert Context.context_fun_spec(schema) == "%{optional(:name) => String.t() | nil}"
    end

    test "without nullable" do
      schema =
        Gen.Schema.build(~w/Shop.Article articles category:enum:food:nonfood/, [])

      assert Context.context_fun_spec(schema) == "%{optional(:category) => :food | :nonfood}"
    end
  end

  describe "*_args/1" do
    test "create_args", %{schema: schema} do
      assert Context.create_args(schema) == "article_attrs, preloads \\ nil"
    end

    test "update_args", %{schema: schema} do
      assert Context.update_args(schema) == "article_id, article_attrs, preloads \\ nil"
    end
  end

  describe "build_assocs/2" do
    test "assocs are retrieved from schema_attrs", %{schema: schema} do
      schema = Map.put(schema, :assocs, Enum.map(schema.assocs, &Punkix.Schema.Assoc.new/1))

      assert Context.build_assocs(schema) == "articles: article_attrs[:category]"
    end
  end

  describe "args_to_params/2" do
    test "returns the correct params" do
      schema =
        Gen.Schema.build(~w/Shop.Article articles name:string/, [])

      assert Context.args_to_params(schema, :create) == "%{name: \"some name\"}"
    end

    test "without nullable" do
      schema =
        Gen.Schema.build(~w/Shop.Article articles category:enum:food:nonfood/, [])

      assert Context.args_to_params(schema, :create) == "%{category: :food}"
    end
  end

  describe "invalid_args_to_params/2" do
    test "returns the correct params" do
      schema =
        Gen.Schema.build(~w/Shop.Article articles name:string/, [])

      assert Context.invalid_args_to_params(schema, :create) == "name: nil"
    end
  end
end
