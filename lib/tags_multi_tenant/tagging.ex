defmodule TagsMultiTenant.Tagging do
  use Ecto.Schema
  import Ecto.Changeset

  @taggable_id_type if Application.compile_env(:tags_multi_tenant, :taggable_id) == :uuid,
                      do: :binary_id,
                      else: :integer

  schema "taggings" do
    field(:taggable_id, @taggable_id_type)
    field(:taggable_type, :string)
    field(:context, :string)

    timestamps(updated_at: false)

    belongs_to(:tag, TagsMultiTenant.Tag)
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:taggable_id, :taggable_type, :context, :tag_id])
    |> validate_required([:taggable_id, :taggable_type, :context, :tag_id])
  end
end
