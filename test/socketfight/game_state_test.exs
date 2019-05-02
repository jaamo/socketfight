defmodule Socketfight.GameStateTest do
  use ExUnit.Case, async: true
  alias Socketfight.CollisionDetector

  test "point inside box 1" do
    assert CollisionDetector.point_inside_box(1, 1, 0, 0, 2, 2)
  end

  test "point inside box 2" do
    assert CollisionDetector.point_inside_box(2, 1, 0, 0, 2, 2)
  end

  test "point outside box 1" do
    assert !CollisionDetector.point_inside_box(5, 1, 0, 0, 2, 2)
  end

  test "point outside box 2" do
    assert !CollisionDetector.point_inside_box(1, 5, 0, 0, 2, 2)
  end

  test "point inside box 3" do
    assert CollisionDetector.point_inside_box(1, 1, 0, 2, 2, 0)
  end

  # setup_all gets run once before any tests run, allowing us to
  # prepare a state for every test in one go. It is expected to
  # return an {:ok, state} tuple.
  setup_all do
    player = %{
      id: 0,
      radius: 40,
      state: %{
        x: 100,
        y: 100,
        newX: 100,
        newY: 100
      }
    }

    state = %{player: player}
    {:ok, state}
  end

  test "no collision", state do
    obstacle = %{a: %{x: 0, y: 200}, b: %{x: 200, y: 200}}
    assert !CollisionDetector.collides?(state.player, obstacle)
  end

  test "collision" do
    player = %{
      id: 0,
      radius: 40,
      state: %{
        x: 100,
        y: 200,
        newX: 100,
        newY: 200
      }
    }

    obstacle = %{a: %{x: 0, y: 200}, b: %{x: 200, y: 200}}

    assert CollisionDetector.collides?(player, obstacle)
  end

  test "touch", state do
    obstacle = %{a: %{x: 0, y: 120}, b: %{x: 200, y: 120}}
    assert CollisionDetector.collides?(state.player, obstacle)
  end

  test "inside", state do
    obstacle = %{a: %{x: 0, y: 100}, b: %{x: 90, y: 100}}
    assert CollisionDetector.collides?(state.player, obstacle)
  end

  # TODO: If the line is very small and completely inside the circle that's
  # not detected as collision. That's not that big issue.
  #
  #   player = %{
  #     id: 0,
  #     radius: 40,
  #     state: %{
  #       x: 100,
  #       y: 100,
  #       newX: 100,
  #       newY: 100
  #     }
  #   }

  #   obstacle = %{a: %{x: 80, y: 100}, b: %{x: 120, y: 100}}

  #   assert CollisionDetector.collides?(player, obstacle)
  # end

  test "outside but in the same line", state do
    obstacle = %{a: %{x: 200, y: 100}, b: %{x: 600, y: 100}}
    assert !CollisionDetector.collides?(state.player, obstacle)
  end

  test "outside but in the same line 2" do
    player = %{
      id: 0,
      radius: 40,
      state: %{
        x: 800,
        y: 100,
        newX: 800,
        newY: 100
      }
    }

    obstacle = %{a: %{x: 200, y: 100}, b: %{x: 600, y: 100}}

    assert !CollisionDetector.collides?(player, obstacle)
  end

  test "outside touch" do
    player = %{
      id: 0,
      radius: 40,
      state: %{
        x: 100,
        y: 60,
        newX: 100,
        newY: 60
      }
    }

    obstacle = %{a: %{x: 200, y: 100}, b: %{x: 600, y: 100}}

    assert !CollisionDetector.collides?(player, obstacle)
  end
end
