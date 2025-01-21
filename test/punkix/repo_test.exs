defmodule Punkix.RepoTest do
  use ExUnit.Case

  alias Punkix.Repo

  defmodule RelatedSchema do
    use Ecto.Schema

    schema "related_schemas" do
      field(:name, :string)
      belongs_to(:test_schema, TestSchema)
    end
  end

  defmodule TestSchema do
    use Ecto.Schema

    schema "test_schemas" do
      field(:name, :string)
      has_many(:schemas, RelatedSchema)
      belongs_to(:nested, RelatedSchema)
    end
  end

  describe "with_assocs/2" do
    test "builds struct with belongs_to assoc" do
      Repo.with_assocs(%RelatedSchema{}, %{test_schema: %TestSchema{id: 1}})
      |> IO.inspect()
    end
  end

  describe "find_preloads/1" do
    test "gets 1 depth preloads" do
      assert [schemas: []] == Repo.find_preloads(%TestSchema{schemas: [%RelatedSchema{}]})
    end

    test "gets arbitrary depth preloads" do
      assert [schemas: [test_schema: []]] ==
               Repo.find_preloads(%TestSchema{
                 schemas: [%RelatedSchema{test_schema: %TestSchema{}}]
               })
    end
  end
end
