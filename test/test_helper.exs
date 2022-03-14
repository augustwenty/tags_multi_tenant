Mix.Task.run "ecto.create", ~w(-r TagsMultiTenant.Repo)
Mix.Task.run "ecto.migrate", ~w(-r TagsMultiTenant.Repo)

TagsMultiTenant.Repo.start_link

ExUnit.start()
