defmodule Punkix.ContextTest do
  alias Punkix.Context
  alias Mix.Tasks.Phx.Gen

  use ExUnit.Case

  describe "context_fun_spec/1" do
    test "with nullable" do
      schema =
        Gen.Schema.build(~w/Shop.Article articles name:string/, [])

      assert Context.context_fun_spec(schema) == "String.t() | nil"
    end

    test "without nullable" do
      schema =
        Gen.Schema.build(~w/Shop.Article articles category:enum:food:nonfood/, [])

      assert Context.context_fun_spec(schema) == ":food | :nonfood"
    end
  end
end
