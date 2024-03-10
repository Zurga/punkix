defmodule Punkix.Shop.Article do
  use Ecto.Schema

  schema "articles" do
    field :description, :string
    field :name, :string
    field :schemas, :string

    timestamps()
  end
end
