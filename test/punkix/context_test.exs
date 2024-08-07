defmodule Punkix.ContextTest do
  alias Punkix.Context
  alias Mix.Tasks.Phx.Gen

  use ExUnit.Case

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
