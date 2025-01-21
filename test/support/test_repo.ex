defmodule TestRepo do
  use Punkix.Repo, otp_app: :punkix, adapter: Ecto.Adapters.Postgres
end

defmodule TestCase do
  use Ecto.Schema

  schema "cases" do
    field(:name, :string)
    belongs_to(:test, Test)
  end
end

defmodule Test do
  use Ecto.Schema

  schema "test" do
    has_many(:cases, TestCase)
  end
end

defmodule TestMigration do
  use Ecto.Migration

  def up do
  end
end
