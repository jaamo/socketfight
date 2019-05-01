defmodule AssertionTest do
  use ExUnit.Case, async: true
  alias Socketfight.CollisionDetector

  test "no collision" do
    player = %{
      id: 0,
      radius: 40,
      state: %{
        x: 100,
        y: 100
      }
    }

    obstacle = %{a: %{x: 0, y: 200}, b: %{x: 200, y: 200}}

    assert !CollisionDetector.collides?(player, obstacle)
  end

  test "collision" do
    player = %{
      id: 0,
      radius: 40,
      state: %{
        x: 100,
        y: 200
      }
    }

    obstacle = %{a: %{x: 0, y: 200}, b: %{x: 200, y: 200}}

    assert CollisionDetector.collides?(player, obstacle)
  end

  test "touch" do
    player = %{
      id: 0,
      radius: 40,
      state: %{
        x: 100,
        y: 100
      }
    }

    obstacle = %{a: %{x: 0, y: 120}, b: %{x: 200, y: 120}}

    assert CollisionDetector.collides?(player, obstacle)
  end

  test "inside" do
    player = %{
      id: 0,
      radius: 40,
      state: %{
        x: 100,
        y: 100
      }
    }

    obstacle = %{a: %{x: 0, y: 100}, b: %{x: 90, y: 100}}

    assert CollisionDetector.collides?(player, obstacle)
  end

  test "inside 2" do
    player = %{
      id: 0,
      radius: 40,
      state: %{
        x: 100,
        y: 100
      }
    }

    obstacle = %{a: %{x: 80, y: 100}, b: %{x: 120, y: 100}}

    assert CollisionDetector.collides?(player, obstacle)
  end
end
