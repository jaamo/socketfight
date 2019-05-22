defmodule Socketfight.GameStateTest do
  use ExUnit.Case, async: true
  alias Socketfight.CollisionDetector

  test "point inside box 1" do
    assert CollisionDetector.point_inside_box(1, 1, 0, 0, 2, 2)
  end

  test "point inside box 2" do
    assert CollisionDetector.point_inside_box(2, 1, 0, 0, 2, 2)
  end

  test "point outside box 2" do
    assert !CollisionDetector.point_inside_box(1, 5, 0, 0, 2, 2)
  end

  test "point inside box 3" do
    assert CollisionDetector.point_inside_box(1, 1, 0, 2, 2, 0)
  end

  test "no collision" do
    assert match?(
             {false},
             CollisionDetector.collides?(
               100,
               100,
               40,
               0,
               200,
               200,
               200
             )
           )
  end

  test "collision" do
    assert match?(
             {true, _},
             CollisionDetector.collides?(
               100,
               200,
               40,
               0,
               200,
               200,
               200
             )
           )
  end

  test "touch" do
    assert match?(
             {true, _},
             CollisionDetector.collides?(
               100,
               100,
               40,
               0,
               120,
               200,
               120
             )
           )
  end

  test "inside" do
    assert match?(
             {true, _},
             CollisionDetector.collides?(
               100,
               100,
               40,
               0,
               100,
               90,
               100
             )
           )
  end

  test "outside but in the same line" do
    assert match?(
             {false},
             CollisionDetector.collides?(
               100,
               100,
               40,
               200,
               100,
               600,
               100
             )
           )
  end

  test "outside but in the same line 2" do
    assert match?(
             {false},
             CollisionDetector.collides?(
               800,
               100,
               40,
               200,
               100,
               600,
               100
             )
           )
  end

  test "outside touch" do
    assert match?(
             {false},
             CollisionDetector.collides?(
               100,
               60,
               40,
               200,
               100,
               600,
               100
             )
           )
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
end
