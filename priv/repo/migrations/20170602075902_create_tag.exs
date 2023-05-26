defmodule TagsMultiTenant.Repo.Migrations.CreateTag do
  use Ecto.Migration

  def change do
    create table(:tags) do
      add(:name, :string, null: false)
    end

    create_if_not_exists(unique_index(:tags, [:name], name: :tags_name_key))
  end
end
