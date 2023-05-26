defmodule TagsMultiTenant.Repo.Migrations.UpdateTagUniqueIndex do
  use Ecto.Migration

  def change do
    drop_if_exists(unique_index(:tags, [:name], name: :tags_name_key))

    create_if_not_exists(unique_index(:tags, [:name], name: :tags_name_key))
  end
end
