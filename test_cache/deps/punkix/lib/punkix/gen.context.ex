defmodule Punkix.Gen.Context do
  # use Punkix.Patcher,
  #   wrap: [
  #     {Mix.Tasks.Phx.Gen.Context, :build, 1, :do_patch}
  #     # {Mix.Tasks.Phx.Gen.Schema, :build, 2, :patch_schema}
  #   ]

  # def do_patch({context, schema}) do
  #   context = %{context | dir: nil}
  #   {context, schema}
  #   raise "Context"
  # end

  # defdelegate patch_schema(schema), to: Punkix.Gen.Schema
end
