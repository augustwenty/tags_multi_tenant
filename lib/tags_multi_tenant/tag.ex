defmodule TagsMultiTenant.Tag do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tags" do
    field(:name, :string)

    has_many(:taggings, TagsMultiTenant.Tagging)
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name])
    |> unique_constraint(:unique_tag_name, name: :tags_name_key)
    |> validate_required(:name)
  end
end
