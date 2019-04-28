defmodule AssertionTest do
  use ExUnit.Case, async: true
  alias Socketfight.CollisionDetector

  """

            *  *
         *        *
        *          *
        *          *
         *        *
            *  *


  ------------------------

  """
  test "no collision" do

    player = %{
      id: 0,
      state: %{
        x: 540,
        y: 360,
      }
    }
    obstacle = %{a: %{x: 100, y: 100}, b: %{x: 800, y: 100}}

    assert CollisionDetector.collides(player, obstacle)
  end
end
