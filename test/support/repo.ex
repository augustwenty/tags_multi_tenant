defmodule Tags_Multi_Tenant.Repo do
  use Ecto.Repo, otp_app: :taglet, adapter: Ecto.Adapters.Postgres
end
