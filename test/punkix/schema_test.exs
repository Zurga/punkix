defmodule Punkix.SchemaTest do
  use ExUnit.Case

  use Punkix

  alias Mix.Tasks.Phx.Gen

  setup do
    [
      schema:
        Gen.Schema.build(
          ~w"Article articles name:string description:string category_id:references:article_categories,required:true,reverse:Article.Category.articles",
          []
        )
        |> Punkix.Patches.Schema.patch_schema()
    ]
  end

  describe "set_assocs" do
    test "setup correct assocs", %{schema: schema} do
      schema
      |> IO.inspect()
    end
  end
end
