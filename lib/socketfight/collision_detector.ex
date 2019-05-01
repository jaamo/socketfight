defmodule Socketfight.CollisionDetector do
  # https://stackoverflow.com/a/1088058
  # https://i.stack.imgur.com/P556i.png
  def collides?(player, obstacle) do
    # Prepare variables.
    # Line start end end.
    ax = obstacle.a.x
    ay = obstacle.a.y
    bx = obstacle.b.x
    by = obstacle.b.y

    # Circle.
    cx = player.state.newX
    cy = player.state.newY
    r = player.radius

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
    lec = :math.sqrt(:math.pow(ex - cx, 2) + :math.pow(ey - cy, 2))

    # Test if the line intersects the circle.
    cond do
      lec < r ->
        # Compute distance from t to circle intersection point.
        # _dt = :math.sqrt(:math.pow(r, 2) - :math.pow(lec, 2))

        # Compute first intersection point.
        # _fx = (t - dt) * dx + ax
        # _fy = (t - dt) * dy + ay

        # Compute second intersection point.
        # _gx = (t + dt) * dx + ax
        # _gy = (t + dt) * dy + ay

        true

      # else test if the line is tangent to circle
      lec == r ->
        # tangent point to circle is E
        true

      true ->
        # line doesn't touch circle
        false
    end
  end
end
