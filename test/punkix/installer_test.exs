Mix.shell(Mix.Shell.Process)

defmodule Punkix.InstallerTest do
  use ExUnit.Case, async: true
  import MixHelper

  @tag timeout: :infinity
  test "single project" do
    Application.put_env(:punkix, :dep, ~s[path: "../../../"])

    in_tmp("test", fn project_path, project_name ->
      Mix.Tasks.Punkix.run(~w/--no-install #{project_path}/)
      put_cache(project_path)

      assert_file("mix.exs", ~w/punkix/)

      assert_file("mix.exs", fn content ->
        refute content =~ "tailwind"
      end)

      for file <- Path.wildcard("../../priv/templates/**/*") do
        assert_file(file)
      end

      for file <- ~w/component channel live_component live_view controller/ do
        assert_file(Path.join(project_path, "lib/#{project_name}_web/#{file}.ex"))
      end

      assert {_, 0} = mix_cmd(project_path, ~w/deps.get/)
      assert {_, 0} = mix_cmd(project_path, ~w/compile --warnings-as-errors/)

      for asset_cmd <- ~w/build deploy/ do
        assert {_, 0} = mix_cmd(project_path, ["assets.#{asset_cmd}"])
      end

      assert {_, 0} = mix_cmd(project_path, ~w/test/)
    end)
  end
end
