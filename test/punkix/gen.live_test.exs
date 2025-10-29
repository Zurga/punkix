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

      assert {_, 0} = mix_cmd(project_path, "gettext.extract")
      assert {_, 0} = mix_cmd(project_path, "gettext.merge", "priv/gettext --locale nl")
      assert_file(Path.join(project_path, "priv/gettext/nl/LC_MESSAGES/default.po"))
      assert_file(Path.join(project_path, "priv/gettext/nl/LC_MESSAGES/routes.po"))
      assert {_, 0} = mix_cmd(project_path, "compile", "--force")
      {routes, 0} = mix_cmd(project_path, "phx.routes", "", into: fn -> "" end)
      assert routes =~ "nl/"
    end)
  end

  test "router instructions" do
    app_name = "Test"

    schema =
      "Persons Person persons name:string description:string articles:references:articles,reverse:Articles.Article.writer,foreign_key:writer_id,type:belongs_to"
      |> String.split(" ")
      |> Mix.Tasks.Phx.Gen.Context.build([])
      |> then(&(elem(&1, 1) |> Map.put(:web_namespace, app_name <> "Web")))
      |> Punkix.Schema.set_assocs()

    schema
    |> Mix.Tasks.Punkix.Gen.Live.live_route_instructions()
    |> Enum.join("")
    |> IO.puts()
  end
end
