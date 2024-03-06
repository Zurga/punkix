Code.require_file("../mix_helper.exs", __DIR__)

defmodule Mix.Tasks.Phx.Gen.ContextTest do
  use ExUnit.Case
  import MixHelper
  alias Mix.Tasks.Phx.Gen
  alias Mix.Phoenix.{Context, Schema}

  setup do
    Mix.Task.clear()
    :ok
  end

  test "new_context", config do
    IO.inspect(config.test)

    in_tmp_project(config.test, fn ->
      Gen.Context.run(~w"Shop Article articles name:string description:string")
      assert Code.compile_file("lib/punkix/shop/article.ex")
      assert Code.compile_file("lib/punkix/shop.ex")

      assert_file("lib/punkix/shop.ex", fn file ->
        IO.puts(file)
      end)
    end)
  end
end
