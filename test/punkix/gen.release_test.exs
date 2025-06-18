defmodule Punkix.Gen.ReleaseTest do
  use ExUnit.Case, async: true
  import MixHelper
  import Punkix.Test.Support.Gen.Web

  @tag timeout: :infinity

  test "add seed to phx.gen.release" do
    Application.put_env(:punkix, :dep, ~s[path: "../../../"])

    in_tmp("test", fn project_path, project_name ->
      assert {_, 0} = mix_cmd(project_path, "punkix.gen.release", "")

      assert_file(
        Path.join(project_path, "lib/#{project_name}/release.ex"),
        "seed"
      )
    end)
  end
end
