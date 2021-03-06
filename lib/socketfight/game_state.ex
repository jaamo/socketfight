# Collision detection:
# https://learnopengl.com/In-Practice/2D-Game/Collisions/Collision-detection

defmodule Socketfight.GameState do
  use Agent
  alias Socketfight.CollisionDetector

  # @arena_width 1080
  # @arena_height 720

  def obstacles() do
    [
      # Edges
      %{a: %{x: 0, y: 0}, b: %{x: 1080, y: 0}},
      %{a: %{x: 1080, y: 0}, b: %{x: 1080, y: 720}},
      %{a: %{x: 0, y: 720}, b: %{x: 1080, y: 720}},
      %{a: %{x: 0, y: 0}, b: %{x: 0, y: 720}},
      # Other obstacles
      %{a: %{x: 200, y: 200}, b: %{x: 880, y: 200}},
      %{a: %{x: 200, y: 520}, b: %{x: 880, y: 520}}
    ]
  end

  @doc """
  Used by the supervisor to start the Agent that will keep the game state persistent.
  The initial value passed to the Agent is an empty map.
  """
  def start_link(_) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  @doc """
  Put a new player in the map
  """
  def put_player(player) do
    Agent.update(__MODULE__, &Map.put_new(&1, player.id, player))
    # fn map -> Map.put(map, player.id, player) end
    player
  end

  @doc """
  Retrieve a player from the map
  """
  def get_player(player_id) do
    Agent.get(__MODULE__, &Map.get(&1, player_id))
  end

  @doc """
  Update the player information in the map
  """
  def update_player(player) do
    Agent.update(__MODULE__, &Map.put(&1, player.id, player))
    player
  end

  @doc """
  """
  def delete_player(player) do
    IO.puts("Delete player #{player.id}")
  end

  @doc """
  Get all the players in the map
  """
  def players do
    Agent.get(__MODULE__, & &1)
  end

  def update_player_action(player_id, action, state) do
    player = get_player(player_id)

    cond do
      player ->
        player
        |> update_player_meta(action, state)
        |> update_player
    end
  end

  def update_player_meta(player, key, value) do
    player
    |> put_in([:actions, key], value)
  end

  @doc """
  Calculate game tick.
  """
  def tick() do
    Enum.each(players(), fn {_key, player} ->
      # Setup shoot cooldown
      player =
        cond do
          player.state.shootCooldown > 0 ->
            update_in(player, [:state, :shootCooldown], fn shootCooldown -> shootCooldown - 1 end)

          true ->
            player
        end

      # Reset collision state.
      updated_player = update_in(player, [:state, :collision], fn _ -> false end)

      # Reset shot state.
      updated_player = update_in(updated_player, [:state, :shot], fn _ -> false end)

      # Filter out names of active actions.
      taken_actions =
        updated_player.actions
        |> Enum.filter(fn {_action, state} -> state == true end)
        |> Enum.map(fn {action, _state} -> action end)

      # Run action handlers.
      updated_player =
        taken_actions
        |> Enum.reduce(updated_player, fn action, player -> handle_player(player, action) end)

      # Handle damage dealt by shooting.
      deal_damage(updated_player, players(), updated_player.state.shot)

      # Clean players with less than zero health.
      players()
      |> Enum.filter(fn {_, player} -> player.state.health <= 0 end)
      |> Enum.map(fn {_, player} -> handle_death(player) end)

      # Run collision detection. If no collisions, move player. Otherwise cancel move.
      if !Enum.any?(obstacles(), fn obstacle ->
           elem(
             CollisionDetector.collides?(
               player.state.newX,
               player.state.newY,
               player.radius,
               obstacle.a.x,
               obstacle.a.y,
               obstacle.b.x,
               obstacle.b.y
             ),
             0
           )
         end) do
        # Move player to the new position.
        updated_player =
          update_in(updated_player, [:state, :x], fn _ -> updated_player.state.newX end)

        updated_player =
          update_in(updated_player, [:state, :y], fn _ -> updated_player.state.newY end)

        # Update player.
        updated_player |> update_player
      else
        # Update player.
        updated_player |> update_player
      end
    end)
  end

  @doc """
  Check if player has shot and deal damage to players hit by bullet. Returns
  a player with updated kills status.
  """
  def deal_damage(player, players, true) do
    # Loop through each opponent. Check collisions.
    players_hit =
      players
      |> Enum.filter(fn {_, target_player} ->
        elem(
          CollisionDetector.collides?(
            target_player.state.x,
            target_player.state.y,
            target_player.radius,
            player.state.x,
            player.state.y,
            player.state.shootTargetX,
            player.state.shootTargetY
          ),
          0
        )
      end)

    # Order list based on distance.

    # Loop through hit players
    players_hit
    |> Enum.map(fn {_, target_player} ->
      # Reduce target player health.
      update_in(target_player, [:state, :health], fn health -> health - 20 end)
      |> update_player
    end)
  end

  @doc """
  In case weapon is not shot, no damage is done.
  """
  def deal_damage(player, _, _) do
    player
  end

  @doc """
  If player dies, increase death counter and reset location.
  """
  def handle_death(player) do
    player
    |> update_in([:state, :health], fn _ -> 100 end)
    |> update_in([:state, :deaths], fn deaths -> deaths + 1 end)
    |> update_player
  end

  # def handle_bullet_damage(player, players) do
  # end

  def handle_player(player, "forward") do
    xOffset = :math.cos(player.state.rotation + :math.pi() / 2) * 5
    yOffset = :math.sin(player.state.rotation + :math.pi() / 2) * 5
    player = update_in(player, [:state, :newX], fn _ -> player.state.x - xOffset end)
    update_in(player, [:state, :newY], fn _ -> player.state.y - yOffset end)
  end

  def handle_player(player, "brake") do
    xOffset = :math.cos(player.state.rotation + :math.pi() / 2) * 5
    yOffset = :math.sin(player.state.rotation + :math.pi() / 2) * 5
    player = update_in(player, [:state, :newX], fn x -> x + xOffset end)
    update_in(player, [:state, :newY], fn y -> y + yOffset end)
  end

  def handle_player(player, "left") do
    update_in(player, [:state, :rotation], fn rotation -> rotation - :math.pi() / 60 end)
  end

  def handle_player(player, "right") do
    update_in(player, [:state, :rotation], fn rotation -> rotation + :math.pi() / 60 end)
  end

  @doc """
  Shoot weapon.
  """
  def handle_player(player, "shoot") do
    # If cooldown is over and shoot-button is enabled.
    if player.state.shootCooldown == 0 && player.actions["shoot"] == true do
      # Calculate end point.
      xOffset = :math.cos(player.state.rotation + :math.pi() / 2) * 400
      yOffset = :math.sin(player.state.rotation + :math.pi() / 2) * 400
      IO.puts("Shoot to: #{xOffset} #{yOffset}")

      # Update states.
      player = update_in(player, [:state, :shootTargetX], fn _ -> player.state.x - xOffset end)
      player = update_in(player, [:state, :shootTargetY], fn _ -> player.state.y - yOffset end)
      player = update_in(player, [:state, :shot], fn _ -> true end)
      update_in(player, [:state, :shootCooldown], fn _ -> 30 end)
    else
      player
    end
  end
end
