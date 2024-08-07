Mix.shell(Mix.Shell.Process)

defmodule Punkix.GenLiveTest do
  use ExUnit.Case, async: true
  import MixHelper
  import Punkix.Test.Support.Gen.Live

  @tag timeout: :infinity
  test "new_live" do
    Application.put_env(:punkix, :dep, ~s[path: "../../../"])

    in_tmp("test", fn project_path, project_name ->
      gen_live(project_path, project_name)
    end)
  end
end
