defmodule Punkix.LiveSessionTest do
  use ExUnit.Case
  alias Punkix.Web.LiveSession

  defmodule TestSchema do
    use Ecto.Schema

    schema "test_schema" do
      has_many(:schemas, RelatedSchema)
    end
  end

  defmodule RelatedSchema do
    use Ecto.Schema

    schema "related" do
      has_many(:other_schemas, OtherSchema)
      belongs_to(:test_schema, TestSchema)
    end
  end

  defmodule OtherSchema do
    use Ecto.Schema

    schema "other" do
      belongs_to(:test_schema, TestSchema)
    end
  end

  describe "assoc_tree/1" do
    test "assoc_tree when no related schemas are preloaded" do
      assert %{
               TestSchema => [RelatedSchema, OtherSchema],
               RelatedSchema => [TestSchema],
               OtherSchema => [TestSchema]
             } == LiveSession.assoc_tree(%TestSchema{})
    end

    test "belongs to has changed" do
      assert [{TestSchema, nil}] ==
               LiveSession.assoc_tree(%RelatedSchema{test_schema: %TestSchema{}})
    end
  end
end
