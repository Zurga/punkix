defmodule Punkix.ContextTest do
  use ExUnit.Case
  use Punkix
  use Punkix.Patches.Schema

  alias Punkix.Context
  alias Mix.Tasks.Phx.Gen

  @schema ~w"Shop.Article articles name:string description:string category_id:references:article_categories,type:belongs_to,required:true,reverse:Article.Category.articles"

  @schema_with_auth @schema ++
                      ~w/user_id:references:users,type:belongs_to,is_current_user:true,reverse:Accounts.User,required:true/

  setup do
    [
      schema: Gen.Schema.build(@schema, []) |> Punkix.Schema.set_assocs(),
      schema_with_user: Gen.Schema.build(@schema_with_auth, []) |> Punkix.Schema.set_assocs()
    ]
  end

  describe "assoc_fixtures/1" do
    test "without auth", %{schema: schema} do
    end

    test "with auth", %{schema_with_user: schema} do
      IO.inspect(schema)
      assert Context.assoc_fixtures(schema) == "\n  import Punkix.AccountsFixtures"
    end
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
      assert Context.create_args(schema) ==
               "%{category: category} = article_attrs, preloads \\\\ nil"
    end

    test "update_args", %{schema: schema} do
      assert Context.update_args(schema) == "article_id, article_attrs, preloads \\\\ nil"
    end
  end

  describe "build_assocs/2" do
    test "assocs are retrieved from schema_attrs", %{schema: schema} do
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

  describe "maybe_separate_assoc" do
    test "splits args up correctly" do
      schema =
        Gen.Schema.build(
          ~w/Shop.Post posts name:string tags:references:tags,type:many_to_many,through:test,reverse:Tags/,
          []
        )
        |> Punkix.Schema.set_assocs()

      assert "{%{tags: tags}, post_attrs} = Map.split(post_attrs, [:tags])\n" =
               Context.maybe_separate_assoc(schema)
    end
  end

  describe "maybe_put_assoc" do
    test "splits args up correctly" do
      schema =
        Gen.Schema.build(
          ~w/Shop.Post posts name:string tags:references:tags,type:many_to_many,through:test,reverse:Tags articles:references:articles,type:many_to_many,through:test,reverse:Articles/,
          []
        )
        |> Punkix.Schema.set_assocs()

      assert "|> put_assoc(:tags, tags)\n|> put_assoc(:articles, articles)" ==
               Context.maybe_put_assoc(schema)
    end
  end
end
