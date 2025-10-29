defmodule Punkix.LiveTest do
  use ExUnit.Case

  use Punkix
  use Punkix.Patches.Schema
  alias Punkix.Live

  alias Mix.Tasks.Phx.Gen

  setup do
    [
      schema:
        Gen.Schema.build(
          ~w"Article articles name:string description:string user_id:references:users,type:belongs_to,required:true,is_current_user:true writers:references:persons,type:has_many,reverse:Persons.Person",
          []
        )
        |> Punkix.Schema.set_assocs()
        |> IO.inspect()
    ]
  end

  describe "maybe_insert_current_user" do
    test "current_user is set", %{schema: schema} do
      assert "|> Map.put(:user, ~a|current_user|)" == Live.maybe_insert_current_user(schema)
    end
  end

  describe "assocs_as_fields/1" do
    test "with has_many", %{schema: schema} do
      assert ["writers_ids"] == Live.assocs_as_fields(schema)
    end
  end
end
