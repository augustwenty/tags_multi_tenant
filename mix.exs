defmodule Tags_Multi_Tenant.Mixfile do
  use Mix.Project

  def project do
    [app: :tags_multi_tenant,
     name: "Tags_Multi_Tenant",
     version: "0.1.0",
     elixir: "~> 1.10",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     elixirc_paths: elixirc_paths(Mix.env),
     package: package(),
     deps: deps(),
     description: description(),
     source_url: "https://github.com/augustwenty/tags_multi_tenant",
     docs: [main: "Tags_Multi_Tenant", extras: ["README.md"]]
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:ecto_sql, "~> 3.0"},
      {:postgrex, ">= 0.16.2"},
      {:inflex, "~> 1.8.1"},
      {:ex_doc, "~> 0.14", only: :dev, runtime: false},
    ]
  end

  defp package do
    [
      maintainers: ["ddaugher"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/augustwenty/tags_multi_tenant",
        "Docs" => "https://hexdocs.pm/tags_multi_tenant/TagsMultiTenant.html"
      }
    ]
  end

  defp description do
    """
    Recreating the Tags_Multi_Tenant project in order to support tagging
    requirements for my project
    """
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(:ci), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
