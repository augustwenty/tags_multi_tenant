defmodule Tags_Multi_TenantPost do
  use Ecto.Schema
  use Tags_Multi_Tenant.TagAs, :tags
  use Tags_Multi_Tenant.TagAs, :categories

  import Ecto.Changeset

  schema "posts" do
    field :title, :string
    field :body, :boolean

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:title, :body])
    |> validate_required([:title])
  end
end
