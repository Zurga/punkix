Mix.shell(Mix.Shell.Process)

defmodule Punkix.CredoTest do
  use ExUnit.Case, async: true
  import MixHelper

  @tag timeout: :infinity
  test "new_live" do
    Application.put_env(:punkix, :dep, ~s[path: "../../../"])

    in_tmp("test", fn project_path, project_name ->
      Mix.Tasks.Punkix.run(~w"--no-install #{project_path}")

      put_cache(project_path)
      assert {_, 0} = mix_cmd(project_path, "deps.get")
      assert {_, 0} = mix_cmd(project_path, "credo", "suggest -a")
    end)
  end
end
