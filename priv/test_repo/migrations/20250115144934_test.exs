defmodule TestRepo.Migrations.Test do
  use Ecto.Migration

  def change do

    create_if_not_exists(table("test"))
  end
end
