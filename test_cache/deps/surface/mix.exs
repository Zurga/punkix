defmodule Surface.MixProject do
  use Mix.Project

  @version "0.11.4"

  def project do
    [
      app: :surface,
      version: @version,
      elixir: "~> 1.13",
      description: "A component based library for Phoenix LiveView",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      env: [csrf_token_reader: {Plug.CSRFProtection, :get_csrf_token_for, []}]
    ]
  end

  defp elixirc_paths(:dev), do: ["lib"] ++ catalogues()
  defp elixirc_paths(:test), do: ["lib", "test/support"] ++ catalogues()
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:phoenix_live_view, "~> 0.19.0 or ~> 0.20.10"},
      {:phoenix_html, "~> 3.3.1"},
      {:sourceror, "~> 1.0.0"},
      {:jason, "~> 1.0", only: :test},
      {:floki, "~> 0.35", only: :test},
      {:phoenix_ecto, "~> 4.3", only: :test},
      {:ecto, "~> 3.9.5 or ~> 3.9", only: :test},
      {:ex_doc, ">= 0.31.0", only: :docs}
    ]
  end

  defp docs do
    [
      main: "Surface",
      source_ref: "v#{@version}",
      source_url: "https://github.com/surface-ui/surface",
      groups_for_modules: [
        Components: ~r/Surface.Components/,
        Catalogue: ~r/Catalogue/,
        Compiler: ~r/Compiler/,
        Directives: ~r/Surface.Directive/,
        AST: ~r/AST/,
        Formatter: [~r/Formatter$/, ~r/Formatter.Phase/]
      ],
      nest_modules_by_prefix: [
        Surface.AST,
        Surface.Catalogue,
        Surface.Compiler,
        Surface.Components,
        Surface.Components.Form,
        Surface.Directive,
        Surface.Formatter.Phases
      ],
      extras: [
        "CHANGELOG.md",
        "MIGRATING.md",
        "LICENSE.md"
      ]
    ]
  end

  defp package do
    %{
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/surface-ui/surface"}
    }
  end

  defp catalogues do
    ["priv/catalogue"]
  end
end
