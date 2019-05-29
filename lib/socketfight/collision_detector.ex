defmodule Socketfight.CollisionDetector do
  @doc """
  Check if given circle collides with given line.

  Circle is defined with radius (r) and position (cx, cy).

  Line is defined with two points ax, ay and bx, by.

  Returns tuple {:false, %{x: 0, y: 0, dist: 0}}

  Where the first parameter is collision resolution and the second
  parameter is the closes colliding point to point ax, ay

  References:
  https://stackoverflow.com/a/1088058
  https://i.stack.imgur.com/P556i.png
  """
  def collides?(cx, cy, r, ax, ay, bx, by) do
    # Compute the euclidean distance between A and B.
    lab = distance_between_points(bx, by, ax, ay)
    # ):math.sqrt(round(:math.pow(bx - ax, 2)) + round(:math.pow(by - ay, 2)))

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

        # Calculate intersection points.
        f = %{x: (t - dt) * dx + ax, y: (t - dt) * dy + ay, dist: 0, collides: false}
        g = %{x: (t + dt) * dx + ax, y: (t + dt) * dy + ay, dist: 0, collides: false}

        # Calculate distances to collision points.
        f = update_in(f.dist, fn _ -> distance_between_points(ax, ay, f.x, f.y) end)
        g = update_in(g.dist, fn _ -> distance_between_points(ax, ay, g.x, g.y) end)

        # Get boolean flags if colliding points are on the live.
        f = update_in(f.collides, fn _ -> point_inside_box(f.x, f.y, ax, ay, bx, by) end)
        g = update_in(g.collides, fn _ -> point_inside_box(g.x, g.y, ax, ay, bx, by) end)

        # Create points array.
        points = [f, g]

        # Filter only colliding points.
        colliding_points = Enum.filter(points, fn point -> point.collides end)

        cond do
          # Colliding points are not inside the line. QUIT!
          length(colliding_points) == 0 ->
            {false}

          # Collision! Return collision with closes colliding point.
          true ->
            {true, Enum.min_by(colliding_points, fn point -> point.dist end)}
        end

      # Else test if the line is tangent to circle. Tangent point is E.
      # Test if the point is on the line (A to B).
      lec == r && point_inside_box(ex, ey, ax, ay, bx, by) ->
        {true, %{x: ex, y: ey, dist: distance_between_points(cx, cy, ex, ey), collides: true}}

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
