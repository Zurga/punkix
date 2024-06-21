Mix.shell(Mix.Shell.Process)

defmodule Punkix.GenAuthTest do
  use ExUnit.Case, async: true
  import MixHelper
  import Punkix.Test.Support.Gen.Live

  @tag timeout: :infinity
  test "new_live" do
    Application.put_env(:punkix, :dep, ~s[path: "../../../"])

    in_tmp("test", fn project_path, project_name ->
      mix_cmd(project_path, "punkix.gen.auth Accounts User users")
      mix_cmd(project_path, "deps.get")
      mix_cmd(project_path, "test")
    end)
  end
end
