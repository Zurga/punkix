defmodule PunkixTest do
  use ExUnit.Case
  doctest Punkix

  test "greets the world" do
    assert Punkix.hello() == :world
  end
end
