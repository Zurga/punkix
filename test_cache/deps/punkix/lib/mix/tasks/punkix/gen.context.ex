defmodule Mix.Tasks.Punkix.Gen.Context do
  use Mix.Task

  use Punkix.Patcher

  wrap(Mix.Tasks.Phx.Gen.Context, :build, 1, :patch_context)

  def patch_context({context, schema}) do
    context = %{context | dir: nil}

    {context, schema}
  end

  defdelegate run(args), to: Mix.Tasks.Phx.Gen.Context
end
