Mix.shell(Mix.Shell.Process)

defmodule Punkix.InstallerTest do
  use ExUnit.Case, async: true
  import MixHelper

  @tag timeout: :infinity
  test "single project" do
    Application.put_env(:punkix, :dep, ~s[path: "../../../"])

    in_tmp("test", fn project_path, project_name ->
      assert_file(Path.join(project_path, "mix.exs"), ~w/punkix/)

      assert_file(Path.join(project_path, "mix.exs"), fn content ->
        refute content =~ "tailwind"
      end)

      # Custom files
      for file <- ~w/schema/ do
        assert_file(Path.join(project_path, "lib/#{project_name}/#{file}.ex"))
      end

      # Phx.Gen templates
      for file <- Path.wildcard("../../priv/templates/**/*") do
        assert_file(file)
      end

      # Web files
      for file <- ~w/component channel live_component live_view controller/ do
        assert_file(Path.join(project_path, "lib/#{project_name}_web/#{file}.ex"))
      end

      assert {_, 0} = mix_cmd(project_path, "deps.get")
      assert {_, 0} = mix_cmd(project_path, "compile --warnings-as-errors")

      for asset_cmd <- ~w/build deploy/ do
        assert {_, 0} = mix_cmd(project_path, "assets.#{asset_cmd}")
      end

      assert {_, 0} = mix_cmd(project_path, "test")
    end)
  end
end
