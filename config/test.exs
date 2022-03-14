use Mix.Config

config :logger, level: :info

config :tags_multi_tenant, ecto_repos: [Tags_Multi_Tenant.Repo]

config :tags_multi_tenant, repo: Tags_Multi_Tenant.Repo

config :tags_multi_tenant, Tags_Multi_Tenant.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "tags_multi_tenant_test",
  hostname: "localhost",
  poolsize: 10
