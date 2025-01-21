defmodule TestRepo.Migrations.Case do
  use Ecto.Migration

  def change do
    create_if_not_exists table("cases") do
      add(:name, :string)
      add(:test_id, :integer, references: "test")
    end
  end
end
