defmodule Socketfight.CollisionDetector do
  @doc """
  Check if given circle collides with given line. 

  Circle is defined with radius (r) and position (cx, cy).

  Line is defined with two points ax, ay and bx, by.

  Returns tuple {:false, %{x: 0, y: 0}}

  References:
  https://stackoverflow.com/a/1088058
  https://i.stack.imgur.com/P556i.png
  """
  def collides?(cx, cy, r, ax, ay, bx, by) do
    # Compute the euclidean distance between A and B.
    lab = :math.sqrt(round(:math.pow(bx - ax, 2)) + round(:math.pow(by - ay, 2)))

    # compute the direction vector D from A to B
    dx = (bx - ax) / lab
    dy = (by - ay) / lab

    # The equation of the line AB is x = Dx*t + Ax, y = Dy*t + Ay with 0 <= t <= LAB.

    # Compute the distance between the points A and E, where
    # E is the point of AB closest the circle center (Cx, Cy)
    t = dx * (cx - ax) + dy * (cy - ay)

    # Compute the coordinates of the point E.
    ex = t * dx + ax
    ey = t * dy + ay

    # Compute the euclidean distance between E and C.
    lec = distance_between_points(ex, ey, cx, cy)

    # Test if the line intersects the circle.
    cond do
      # Line is inside the circle. Two intersections.
      lec < r ->
        # Compute distance from t to circle intersection point.
        dt = :math.sqrt(:math.pow(r, 2) - :math.pow(lec, 2))

        # Compute first intersection point.
        fx = (t - dt) * dx + ax
        fy = (t - dt) * dy + ay

        # Compute second intersection point.
        gx = (t + dt) * dx + ax
        gy = (t + dt) * dy + ay

        # Collision if one of the intersection points is on the line.
        cond do
          point_inside_box(fx, fy, ax, ay, bx, by) ->
            {true, %{x: fx, y: fy, distance: distance_between_points(cx, cy, fx, fy)}}

          point_inside_box(gx, gy, ax, ay, bx, by) ->
            {true, %{x: gx, y: gy, distance: distance_between_points(cx, cy, gx, gy)}}

          true ->
            {false}
        end

      # Else test if the line is tangent to circle. Tangent point is E.
      # Test if the point is on the line (A to B).
      lec == r && point_inside_box(ex, ey, ax, ay, bx, by) ->
        {true, %{x: ex, y: ey, distance: distance_between_points(cx, cy, ex, ey)}}

      # Line doesn't touch circle.
      true ->
        {false}
    end
  end

  def distance_between_points(ax, ay, bx, by) do
    :math.sqrt(:math.pow(ax - bx, 2) + :math.pow(ay - by, 2))
  end

  @doc """
  Return true if given point p is inside a rectange defined by points a and b.
  """
  def point_inside_box(px, py, ax, ay, bx, by) do
    px >= Enum.min([ax, bx]) && px <= Enum.max([ax, bx]) && py >= Enum.min([ay, by]) &&
      py <= Enum.max([ay, by])
  end
end
