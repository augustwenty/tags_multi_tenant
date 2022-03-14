defmodule Tags_Multi_Tenant.Repo do
  use Ecto.Repo, otp_app: :tags_multi_tenant, adapter: Ecto.Adapters.Postgres
end
