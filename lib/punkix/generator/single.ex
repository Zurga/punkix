defmodule Punkix.Generator.Single do
  alias Phx.New.Project
  use Punkix.Generator

  template(:new, [
    {:config, :project,
     "phx_single/config/config.exs": "config/config.exs",
     "phx_single/config/dev.exs": "config/dev.exs",
     "phx_single/config/prod.exs": "config/prod.exs",
     "phx_single/config/runtime.exs": "config/runtime.exs",
     "phx_single/config/test.exs": "config/test.exs"},
    {:eex, :web,
     "phx_single/lib/app_name/application.ex": "lib/:app/application.ex",
     "phx_single/lib/app_name.ex": "lib/:app.ex",
     "phx_web/controllers/error_json.ex": "lib/:lib_web_name/controllers/error_json.ex",
     "phx_web/endpoint.ex": "lib/:lib_web_name/endpoint.ex",
     "phx_web/router.ex": "lib/:lib_web_name/router.ex",
     "phx_web/telemetry.ex": "lib/:lib_web_name/telemetry.ex",
     "phx_web/config/integration_test.exs": "config/integration_test.exs",
     "phx_single/lib/app_name_web.ex": "lib/:lib_web_name.ex",
     "phx_single/lib/app_name_web/channel.ex": "lib/:lib_web_name/channel.ex",
     "phx_single/lib/app_name_web/controller.ex": "lib/:lib_web_name/controller.ex",
     "phx_single/lib/app_name_web/component.ex": "lib/:lib_web_name/component.ex",
     "phx_single/lib/app_name_web/form_component.ex": "lib/:lib_web_name/form_component.ex",
     "phx_single/lib/app_name_web/html.ex": "lib/:lib_web_name/html.ex",
     "phx_single/lib/app_name_web/live_component.ex": "lib/:lib_web_name/live_component.ex",
     "phx_single/lib/app_name_web/live_view.ex": "lib/:lib_web_name/live_view.ex",
     "phx_single/lib/app_name_web/live/index_live.ex": "lib/:lib_web_name/live/index_live.ex",
     "phx_single/mix.exs": "mix.exs",
     "phx_single/README.md": "README.md",
     "phx_single/LICENSE.md": "LICENSE.md",
     "phx_single/formatter.exs": ".formatter.exs",
     "phx_single/gitignore": ".gitignore",
     "phx_single/post_commit": ".git/hooks/post-commit",
     "phx_single/default.nix": "default.nix",
     "phx_single/service.nix": "service.nix",
     "phx_test/support/conn_case.ex": "test/support/conn_case.ex",
     "phx_test/support/live_case.ex": "test/support/live_case.ex",
     "phx_single/test/test_helper.exs": "test/test_helper.exs",
     "phx_single/integration_test/test_helper.exs": "integration_test/test_helper.exs",
     "phx_single/integration_test/test.nix": "integration_test/test.nix",
     "phx_test/controllers/error_json_test.exs":
       "test/:lib_web_name/controllers/error_json_test.exs"},
    {:keep, :web,
     "phx_web/controllers": "lib/:lib_web_name/controllers",
     "phx_test/controllers": "test/:lib_web_name/controllers"}
  ])

  template(:gettext, [
    {:eex, :web,
     "phx_gettext/gettext.ex": "lib/:lib_web_name/gettext.ex",
     "phx_gettext/en/LC_MESSAGES/errors.po": "priv/gettext/en/LC_MESSAGES/errors.po",
     "phx_gettext/errors.pot": "priv/gettext/errors.pot"}
  ])

  template(:html, [
    {
      :eex,
      :web,
      # "phx_web/controllers/page_controller.ex": "lib/:lib_web_name/controllers/page_controller.ex",
      # "phx_web/controllers/page_html.ex": "lib/:lib_web_name/controllers/page_html.ex",
      # "phx_web/controllers/page_html/home.html.heex":
      #   "lib/:lib_web_name/controllers/page_html/home.html.heex",
      # "phx_test/controllers/page_controller_test.exs":
      #   "test/:lib_web_name/controllers/page_controller_test.exs",
      "phx_web/components/modal.ex": "lib/:lib_web_name/components/modal.ex",
      "phx_web/components/table.ex": "lib/:lib_web_name/components/table.ex",
      "phx_web/components/table/column.ex": "lib/:lib_web_name/components/table/column.ex",
      "phx_web/controllers/error_html.ex": "lib/:lib_web_name/controllers/error_html.ex",
      "phx_test/controllers/error_html_test.exs":
        "test/:lib_web_name/controllers/error_html_test.exs",
      "phx_web/components/layouts/root.html.heex":
        "lib/:lib_web_name/components/layouts/root.html.heex",
      "phx_web/components/layouts/app.html.heex":
        "lib/:lib_web_name/components/layouts/app.html.heex",
      "phx_web/components/layouts.ex": "lib/:lib_web_name/components/layouts.ex"
    },
    {:eex, :web, "phx_assets/logo.svg": "priv/static/images/logo.svg"}
  ])

  template(:ecto, [
    {:eex, :app,
     "phx_ecto/repo.ex": "lib/:app/repo.ex",
     "phx_ecto/schema.ex": "lib/:app/schema.ex",
     "phx_ecto/formatter.exs": "priv/repo/migrations/.formatter.exs",
     "phx_ecto/seeds.exs": "priv/repo/seeds.exs",
     "phx_ecto/data_case.ex": "test/support/data_case.ex"},
    {:keep, :app, "phx_ecto/priv/repo/migrations": "priv/repo/migrations"}
  ])

  template(:css, [
    {
      :eex,
      :web,
      "phx_assets/app.css": "assets/css/app.css", "phx_assets/pico.css": "assets/css/pico.css"
      # "phx_assets/tailwind.config.js": "assets/tailwind.config.js"}
    }
  ])

  template(:js, [
    {:eex, :web,
     "phx_assets/app.js": "assets/js/app.js", "phx_assets/topbar.js": "assets/vendor/topbar.js"}
  ])

  template(:no_js, [
    {:text, :web, "phx_static/app.js": "priv/static/assets/app.js"}
  ])

  template(:no_css, [
    {:text, :web,
     "phx_static/app.css": "priv/static/assets/app.css",
     "phx_static/home.css": "priv/static/assets/home.css"}
  ])

  template(:static, [
    {:text, :web,
     "phx_static/robots.txt": "priv/static/robots.txt",
     "phx_static/favicon.ico": "priv/static/favicon.ico"}
  ])

  template(:mailer, [
    {:eex, :app, "phx_mailer/lib/app_name/mailer.ex": "lib/:app/mailer.ex"}
  ])

  defdelegate prepare_project(project), to: Phx.New.Single

  def generate(%Project{} = project) do
    copy_from(project, __MODULE__, :new)

    if Project.ecto?(project), do: gen_ecto(project)
    if Project.html?(project), do: gen_html(project)
    if Project.mailer?(project), do: gen_mailer(project)
    if Project.gettext?(project), do: gen_gettext(project)

    gen_assets(project)
    set_git_hook_permissions(project)

    project
  end

  def gen_html(project) do
    copy_from(project, __MODULE__, :html)
  end

  def gen_gettext(project) do
    copy_from(project, __MODULE__, :gettext)
  end

  def gen_ecto(%{binding: binding, project_path: project_path} = project) do
    copy_from(project, __MODULE__, :ecto)

    adapter_config =
      binding[:adapter_config]
      |> put_in(
        [:integration_test],
        Keyword.drop(binding[:adapter_config][:test], [:pool])
      )

    config_inject(project_path, "config/dev.exs", """
    import Config

    # Configure your database
    config :#{binding[:app_name]}, #{binding[:app_module]}.Repo#{kw_to_config(adapter_config[:dev])}
    """)

    config_inject(project_path, "config/test.exs", """
    import Config

    # Configure your database
    #
    # The MIX_TEST_PARTITION environment variable can be used
    # to provide built-in test partitioning in CI environment.
    # Run `mix help test` for more information.
    config :#{binding[:app_name]}, #{binding[:app_module]}.Repo#{kw_to_config(adapter_config[:test])}
    """)

    config_inject(project_path, "config/integration_test.exs", """
    import Config

    # Configure your database
    #
    # The MIX_TEST_PARTITION environment variable can be used
    # to provide built-in test partitioning in CI environment.
    # Run `mix help test` for more information.
    config :#{binding[:app_name]}, #{binding[:app_module]}.Repo#{kw_to_config(adapter_config[:integration_test])}
    """)

    prod_only_config_inject(project_path, "config/runtime.exs", """
    database =
      System.get_env(\"DATABASE\") ||
        raise \"\"\"
        environment variable DATABASE is missing."
        \"\"\"

    config :#{binding[:app_name]}, #{binding[:app_module]}.Repo,
      database: database,
      hostname: "/run/postgresql",
      socket_dir: "/run/postgresql",
      port: 5432,
      pool_size: String.to_integer(System.get_env(\"POOL_SIZE\") || \"10\")
    """)
  end

  def gen_assets(%Project{} = project) do
    javascript? = Project.javascript?(project)
    css? = Project.css?(project)
    html? = Project.html?(project)

    copy_from(project, __MODULE__, :static)

    if html? or javascript? do
      command = if javascript?, do: :js, else: :no_js
      copy_from(project, __MODULE__, command)
    end

    if html? or css? do
      command = if css?, do: :css, else: :no_css
      copy_from(project, __MODULE__, command)
    end
  end

  def gen_mailer(%Project{} = project) do
    copy_from(project, __MODULE__, :mailer)
  end

  defp set_git_hook_permissions(project) do
    File.chmod(Project.join_path(project, :web, ".git/hooks/post-commit"), 0o755)
  end

  defp kw_to_config(kw) do
    Enum.map(kw, fn
      {k, {:literal, v}} -> ",\n  #{k}: #{v}"
      {k, v} -> ",\n  #{k}: #{inspect(v)}"
    end)
  end
end
