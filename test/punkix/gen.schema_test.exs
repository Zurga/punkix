Mix.shell(Mix.Shell.Process)

defmodule Punkix.GenSchemaTest do
  use ExUnit.Case, async: true
  import MixHelper

  @tag timeout: :infinity
  test "new_schema" do
    Application.put_env(:punkix, :dep, ~s[path: "../../../"])

    in_tmp("test", fn project_path, project_name ->
      assert {_, 0} =
               mix_cmd(
                 project_path,
                 "punkix.gen.schema",
                 "Article articles name:string description:string"
               )

      schemas_path = Path.join(project_path, "lib/#{project_name}/schemas")

      assert_file(Path.join(schemas_path, "article.ex"), "typed_schema")

      assert {_, 0} = mix_cmd(project_path, "test")
    end)
  end
end
