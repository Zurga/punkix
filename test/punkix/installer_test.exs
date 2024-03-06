Code.require_file("../mix/mix_helper.exs", __DIR__)

defmodule Punkix.InstallerTest do
  use ExUnit.Case, async: true
  import MixHelper

  defp put_cache(project_name) do
    File.cp_r(
      Path.join(project_name, "/../../../test_cache/deps"),
      Path.join(project_name, "deps")
    )

    File.cp_r(
      Path.join(project_name, "/../../../test_cache/_build"),
      Path.join(project_name, "_build")
    )
  end

  describe "Installer runs and tests pass" do
    @tag timeout: :infinity
    test "single project" do
      Application.put_env(:punkix, :dep, ~s[path: "../../../"])

      in_tmp("test", fn project_name ->
        Mix.Tasks.Punkix.run(~w/--no-install #{project_name}/)
        put_cache(project_name)

        File.cd!(project_name, fn ->
          assert_file("mix.exs", ~w/punkix/)

          assert_file("mix.exs", fn content ->
            refute content =~ "tailwind"
          end)

          for file <- Path.wildcard("../../priv/templates/**/*") do
            assert_file(file)
          end

          assert {_, 0} = mix_cmd(~w/deps.get/)
          assert {_, 0} = mix_cmd(~w/compile --warnings-as-errors/)

          for asset_cmd <- ~w/build deploy/ do
            assert {_, 0} = mix_cmd(["assets.#{asset_cmd}"])
          end

          assert {_, 0} = mix_cmd(~w/test/)
        end)
      end)
    end

    @tag timeout: :infinity
    test "new_context", config do
      Application.put_env(:punkix, :dep, ~s[path: "../../../"])

      in_tmp("test", fn project_name ->
        Mix.Tasks.Punkix.run(~w/--no-install #{project_name}/)

        File.cd!(project_name, fn ->
          put_cache(File.cwd!())
          assert {_, 0} = mix_cmd("deps.get")

          assert {_, 0} =
                   mix_cmd(
                     "punkix.gen.context",
                     ~w"Shop Article articles name:string description:string --context schemas"
                   )

          assert_file("lib/#{project_name}/schemas/article.ex")

          assert {_, 0} = mix_cmd("test")
        end)
      end)
    end
  end
end
