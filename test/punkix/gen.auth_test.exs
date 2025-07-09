# Mix.shell(Mix.Shell.Process)

defmodule Punkix.GenAuthTest do
  use ExUnit.Case, async: true
  import MixHelper
  import Punkix.Test.Support.Gen.Live

  @tag timeout: :infinity
  test "new_live" do
    Application.put_env(:punkix, :dep, ~s[path: "../../../"])

    in_tmp("test", fn project_path, project_name ->
      # mix_cmd(
      #   project_path,
      #   "punkix.gen.context Accounts Organization organizations name:string users:references:users,reverse:Accounts.User"
      # )

      mix_cmd(
        project_path,
        "punkix.gen.auth Accounts User users organization_id:references:organizations,required:true,reverse:Accounts.Organization"
      )

      # mix_cmd(
      #   project_path,
      #   "punkix.gen.auth Accounts User users"
      # )

      # organization_id:references:organizations,required:true,reverse:Accounts.Organization"

      mix_cmd(project_path, "deps.get")
      schemas_path = Path.join(project_path, "lib/#{project_name}/schemas/accounts/")
      assert_file(Path.join(schemas_path, "user.ex"))
      assert_file(Path.join(schemas_path, "user.ex"), "belongs_to :organization, Organization")

      root_layout =
        Path.join(project_path, "lib/#{project_name}_web/components/layouts/root.html.heex")

      assert_file(root_layout, "Log in")

      assert_file(root_layout, fn content ->
        refute content =~ "font-semibold"
      end)

      mix_cmd(project_path, "test")
    end)
  end
end
