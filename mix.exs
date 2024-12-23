defmodule Punkix.MixProject do
  use Mix.Project

  def project do
    [
      app: :punkix,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps(),
      aliases: aliases(),
      compilers: Mix.compilers() ++ [:surface]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:phoenix, "1.7.18"},
      {:phx_new, "1.7.18"},
      {:typed_ecto_schema, "~> 0.4.1"},
      {:sourceror, "~> 1.0.0"},
      {:msgpax, "~> 2.4.0"},
      {:surface, "~> 0.12.0"},
      {:surface_form_helpers, "~> 0.2.0"},
      {:esbuild, "~> 0.2", only: [:dev, :test]},
      {:exflect, "~> 1.0.0"},
      {:plug_cowboy, "~> 2.0", only: :dev},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_ecto, "~> 4.6.2", only: :dev}
    ]
  end

  defp aliases do
    [
      "assets.build": ["esbuild module", "esbuild main"],
      "assets.watch": ["esbuild module --watch"]
    ]
  end
end
