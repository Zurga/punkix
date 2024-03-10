defmodule Punkix.Jokes.SharedJoke do
  use Ecto.Schema

  schema "shared_jokes" do

    field :joke, :id
    field :sharer, :id
    field :sharee, :id

    timestamps()
  end
end
