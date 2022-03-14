defmodule TagsMultiTenant.RepoClient do
  @doc """
  Gets the configured repo module or defaults to Repo if none configured
  """
  def repo, do: Application.get_env(:tags_multi_tenant, :repo, Repo)
end
