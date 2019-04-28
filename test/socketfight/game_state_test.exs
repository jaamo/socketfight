defmodule AssertionTest do
  use ExUnit.Case, async: true
  alias Socketfight.CollisionDetector

  test "no collision" do
    assert CollisionDetector.collides(0, 0)
  end
end
