use Mix.Config

config :logger, level: :info

config :tags_multi_tenant, ecto_repos: [TagsMultiTenant.Repo]

config :tags_multi_tenant, repo: TagsMultiTenant.Repo

config :tags_multi_tenant, TagsMultiTenant.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "tags_multi_tenant_test",
  hostname: "localhost",
  poolsize: 10
