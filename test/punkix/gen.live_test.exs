Mix.shell(Mix.Shell.Process)

defmodule Punkix.GenLiveTest do
  use ExUnit.Case, async: true
  import MixHelper

  @tag timeout: :infinity
  test "new_context" do
    Application.put_env(:punkix, :dep, ~s[path: "../../../"])

    in_tmp("test", fn project_path, project_name ->
      Mix.Tasks.Punkix.run(~w"--no-install #{project_path}")

      put_cache(project_path)
      assert {_, 0} = mix_cmd(project_path, "deps.get")

      assert {_, 0} =
               mix_cmd(
                 project_path,
                 "punkix.gen.live",
                 ~w"Shop Article articles name:string description:string --context schemas"
               )

      # assert_file(Path.join(project_path, "lib/#{project_name}_web/live/article/index.ex"))
      refute_file(Path.join(project_path, "lib/#{project_name}_web/core_components.ex"))

      assert {_, 0} = mix_cmd(project_path, "test")
    end)
  end
end
