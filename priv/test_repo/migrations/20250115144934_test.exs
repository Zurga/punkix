defmodule TestRepo.Migrations.Test do
  use Ecto.Migration

  def change do
    create_if_not_exists table("test") do
      add(:test_case_id, :integer, references: "cases")
    end
  end
end
