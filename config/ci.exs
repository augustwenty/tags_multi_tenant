use Mix.Config

config :logger, level: :info

config :taglet, ecto_repos: [Tags_Multi_Tenant.Repo]

config :taglet, repo: Tags_Multi_Tenant.Repo

config :taglet, Tags_Multi_Tenant.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "taglet_test",
  hostname: "localhost",
  poolsize: 10
