defmodule WarpexTest do
  use ExUnit.Case
  doctest Warpex

  test "greets the world" do
    assert Warpex.hello() == :world
  end
end
