Mix.Task.run "ecto.create", ~w(-r Tags_Multi_Tenant.Repo)
Mix.Task.run "ecto.migrate", ~w(-r Tags_Multi_Tenant.Repo)

Tags_Multi_Tenant.Repo.start_link

ExUnit.start()
