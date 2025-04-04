defmodule Mix.Tasks.Phx.New do
  @moduledoc """
  Creates a new Phoenix project.

  It expects the path of the project as an argument.

      $ mix phx.new PATH [--module MODULE] [--app APP]

  A project at the given PATH will be created. The
  application name and module name will be retrieved
  from the path, unless `--module` or `--app` is given.

  ## Options

    * `--umbrella` - generate an umbrella project,
      with one application for your domain, and
      a second application for the web interface.

    * `--app` - the name of the OTP application

    * `--module` - the name of the base module in
      the generated skeleton

    * `--database` - specify the database adapter for Ecto. One of:

        * `postgres` - via https://github.com/elixir-ecto/postgrex
        * `mysql` - via https://github.com/elixir-ecto/myxql
        * `mssql` - via https://github.com/livehelpnow/tds
        * `sqlite3` - via https://github.com/elixir-sqlite/ecto_sqlite3

      Please check the driver docs for more information
      and requirements. Defaults to "postgres".

    * `--adapter` - specify the http adapter. One of:
        * `cowboy` - via https://github.com/elixir-plug/plug_cowboy
        * `bandit` - via https://github.com/mtrudel/bandit

      Please check the adapter docs for more information
      and requirements. Defaults to "bandit".

    * `--no-assets` - equivalent to `--no-esbuild` and `--no-tailwind`

    * `--no-dashboard` - do not include Phoenix.LiveDashboard

    * `--no-ecto` - do not generate Ecto files

    * `--no-esbuild` - do not include esbuild dependencies and assets.
      We do not recommend setting this option, unless for API only
      applications, as doing so requires you to manually add and
      track JavaScript dependencies

    * `--no-gettext` - do not generate gettext files

    * `--no-html` - do not generate HTML views

    * `--no-live` - comment out LiveView socket setup in your Endpoint 
      and assets/js/app.js. Automatically disabled if --no-html is given

    * `--no-mailer` - do not generate Swoosh mailer files

    * `--no-tailwind` - do not include tailwind dependencies and assets.
      The generated markup will still include Tailwind CSS classes, those
      are left-in as reference for the subsequent styling of your layout
      and components

    * `--binary-id` - use `binary_id` as primary key type in Ecto schemas

    * `--verbose` - use verbose output

    * `-v`, `--version` - prints the Phoenix installer version

  When passing the `--no-ecto` flag, Phoenix generators such as
  `phx.gen.html`, `phx.gen.json`, `phx.gen.live`, and `phx.gen.context`
  may no longer work as expected as they generate context files that rely
  on Ecto for the database access. In those cases, you can pass the
  `--no-context` flag to generate most of the HTML and JSON files
  but skip the context, allowing you to fill in the blanks as desired.

  Similarly, if `--no-html` is given, the files generated by
  `phx.gen.html` will no longer work, as important HTML components
  will be missing.

  ## Installation

  `mix phx.new` by default prompts you to fetch and install your
  dependencies. You can enable this behaviour by passing the
  `--install` flag or disable it with the `--no-install` flag.

  ## Examples

      $ mix phx.new hello_world

  Is equivalent to:

      $ mix phx.new hello_world --module HelloWorld

  Or without the HTML and JS bits (useful for APIs):

      $ mix phx.new ~/Workspace/hello_world --no-html --no-assets

  As an umbrella:

      $ mix phx.new hello --umbrella

  Would generate the following directory structure and modules:

  ```text
  hello_umbrella/   Hello.Umbrella
    apps/
      hello/        Hello
      hello_web/    HelloWeb
  ```

  You can read more about umbrella projects using the
  official [Elixir guide](https://hexdocs.pm/elixir/dependencies-and-umbrella-projects.html#umbrella-projects)
  """
  use Mix.Task
  alias Phx.New.{Generator, Project, Single, Umbrella, Web, Ecto}

  @version Mix.Project.config()[:version]
  @shortdoc "Creates a new Phoenix v#{@version} application"

  @switches [
    dev: :boolean,
    assets: :boolean,
    esbuild: :boolean,
    tailwind: :boolean,
    ecto: :boolean,
    app: :string,
    module: :string,
    web_module: :string,
    database: :string,
    binary_id: :boolean,
    html: :boolean,
    gettext: :boolean,
    umbrella: :boolean,
    verbose: :boolean,
    live: :boolean,
    dashboard: :boolean,
    install: :boolean,
    prefix: :string,
    mailer: :boolean,
    adapter: :string,
    from_elixir_install: :boolean,
  ]

  @impl true
  def run([version]) when version in ~w(-v --version) do
    Mix.shell().info("Phoenix installer v#{@version}")
  end

  def run(argv) do
    elixir_version_check!()

    case OptionParser.parse!(argv, strict: @switches) do
      {_opts, []} ->
        Mix.Tasks.Help.run(["phx.new"])

      {opts, [base_path | _]} ->
        if opts[:umbrella] do
          generate(base_path, Umbrella, :project_path, opts)
        else
          generate(base_path, Single, :base_path, opts)
        end
    end
  end

  @doc false
  def run(argv, generator, path) do
    elixir_version_check!()

    case OptionParser.parse!(argv, strict: @switches) do
      {_opts, []} -> Mix.Tasks.Help.run(["phx.new"])
      {opts, [base_path | _]} -> generate(base_path, generator, path, opts)
    end
  end

  defp generate(base_path, generator, path, opts) do
    base_path
    |> Project.new(opts)
    |> generator.prepare_project()
    |> Generator.put_binding()
    |> validate_project(path)
    |> generator.generate()
    |> prompt_to_install_deps(generator, path)
  end

  defp validate_project(%Project{opts: opts} = project, path) do
    check_app_name!(project.app, !!opts[:app])
    check_directory_existence!(Map.fetch!(project, path))
    check_module_name_validity!(project.root_mod)
    check_module_name_availability!(project.root_mod)

    project
  end

  defp prompt_to_install_deps(%Project{} = project, generator, path_key) do
    path = Map.fetch!(project, path_key)

    install? =
      Keyword.get_lazy(project.opts, :install, fn ->
        Mix.shell().yes?("\nFetch and install dependencies?")
      end)

    cd_step = ["$ cd #{relative_app_path(path)}"]

    maybe_cd(path, fn ->
      mix_step = install_mix(project, install?)

      if mix_step == [] do
        builders = Keyword.fetch!(project.binding, :asset_builders)

        if builders != [] do
          Mix.shell().info([:green, "* running ", :reset, "mix assets.setup"])

          # First compile only builders so we can install in parallel
          # TODO: Once we require Erlang/OTP 28, castore and jason may no longer be required
          cmd(project, "mix deps.compile castore jason #{Enum.join(builders, " ")}", log: false)
        end

        tasks =
          Enum.map(builders, fn builder ->
            cmd = "mix do loadpaths --no-compile + #{builder}.install"
            Task.async(fn -> cmd(project, cmd, log: false, cd: project.web_path) end)
          end)

        if rebar_available?() do
          cmd(project, "mix deps.compile")
        end

        Task.await_many(tasks, :infinity)
      end

      print_missing_steps(cd_step ++ mix_step)

      if Project.ecto?(project) do
        print_ecto_info(generator)
      end

      if path_key == :web_path do
        Mix.shell().info("""
        Your web app requires a PubSub server to be running.
        The PubSub server is typically defined in a `mix phx.new.ecto` app.
        If you don't plan to define an Ecto app, you must explicitly start
        the PubSub in your supervision tree as:

            {Phoenix.PubSub, name: #{inspect(project.app_mod)}.PubSub}
        """)
      end

      print_mix_info(generator)
    end)
  end

  defp maybe_cd(path, func), do: path && File.cd!(path, func)

  defp install_mix(project, install?) do
    if install? && hex_available?() do
      cmd(project, "mix deps.get")
    else
      ["$ mix deps.get"]
    end
  end

  # TODO: Elixir v1.15 automatically installs Hex/Rebar if missing, so we can simplify this.
  defp hex_available? do
    Code.ensure_loaded?(Hex)
  end

  defp rebar_available? do
    Mix.Rebar.rebar_cmd(:rebar3)
  end

  defp print_missing_steps(steps) do
    Mix.shell().info("""

    We are almost there! The following steps are missing:

        #{Enum.join(steps, "\n    ")}
    """)
  end

  defp print_ecto_info(Web), do: :ok

  defp print_ecto_info(_gen) do
    Mix.shell().info("""
    Then configure your database in config/dev.exs and run:

        $ mix ecto.create
    """)
  end

  defp print_mix_info(Ecto) do
    Mix.shell().info("""
    You can run your app inside IEx (Interactive Elixir) as:

        $ iex -S mix
    """)
  end

  defp print_mix_info(_gen) do
    Mix.shell().info("""
    Start your Phoenix app with:

        $ mix phx.server

    You can also run your app inside IEx (Interactive Elixir) as:

        $ iex -S mix phx.server
    """)
  end

  defp relative_app_path(path) do
    case Path.relative_to_cwd(path) do
      ^path -> Path.basename(path)
      rel -> rel
    end
  end

  ## Helpers

  defp cmd(%Project{} = project, cmd, opts \\ []) do
    {log?, opts} = Keyword.pop(opts, :log, true)

    if log? do
      Mix.shell().info([:green, "* running ", :reset, cmd])
    end

    case Mix.shell().cmd(cmd, opts ++ cmd_opts(project)) do
      0 -> []
      _ -> ["$ #{cmd}"]
    end
  end

  defp cmd_opts(%Project{} = project) do
    if Project.verbose?(project) do
      []
    else
      [quiet: true]
    end
  end

  defp check_app_name!(name, from_app_flag) do
    unless name =~ Regex.recompile!(~r/^[a-z][\w_]*$/) do
      extra =
        if !from_app_flag do
          ". The application name is inferred from the path, if you'd like to " <>
            "explicitly name the application then use the `--app APP` option."
        else
          ""
        end

      Mix.raise(
        "Application name must start with a letter and have only lowercase " <>
          "letters, numbers and underscore, got: #{inspect(name)}" <> extra
      )
    end
  end

  defp check_module_name_validity!(name) do
    unless inspect(name) =~ Regex.recompile!(~r/^[A-Z]\w*(\.[A-Z]\w*)*$/) do
      Mix.raise(
        "Module name must be a valid Elixir alias (for example: Foo.Bar), got: #{inspect(name)}"
      )
    end
  end

  defp check_module_name_availability!(name) do
    [name]
    |> Module.concat()
    |> Module.split()
    |> Enum.reduce([], fn name, acc ->
      mod = Module.concat([Elixir, name | acc])

      if Code.ensure_loaded?(mod) do
        Mix.raise("Module name #{inspect(mod)} is already taken, please choose another name")
      else
        [name | acc]
      end
    end)
  end

  defp check_directory_existence!(path) do
    if File.dir?(path) and
         not Mix.shell().yes?(
           "The directory #{path} already exists. Are you sure you want to continue?"
         ) do
      Mix.raise("Please select another directory for installation.")
    end
  end

  defp elixir_version_check! do
    unless Version.match?(System.version(), "~> 1.14") do
      Mix.raise(
        "Phoenix v#{@version} requires at least Elixir v1.14\n " <>
          "You have #{System.version()}. Please update accordingly"
      )
    end
  end
end
