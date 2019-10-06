# Collision detection:
# https://learnopengl.com/In-Practice/2D-Game/Collisions/Collision-detection

defmodule Socketfight.GameState do
  use Agent
  alias Socketfight.CollisionDetector
  alias Socketfight.Player

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
        |> update_player()
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
      player = Player.handle_shoot_cooldown(player)

      # Reset collision state.
      updated_player = Player.reset_collision(player)

      # Reset shot state.
      updated_player = Player.reset_shot_state(updated_player)

      # Filter out names of active actions.
      taken_actions =
        updated_player.actions
        |> Enum.filter(fn {_action, state} -> state == true end)
        |> Enum.map(fn {action, _state} -> action end)

      # Run action handlers.
      updated_player =
        taken_actions
        |> Enum.reduce(updated_player, fn action, player ->
          Player.handle_action(player, action)
        end)

      # Handle damage dealt by shooting.
        damaged_players = Player.deal_damage(updated_player, players(), updated_player.state.shot)

        if is_list(damaged_players) do
          Enum.each(damaged_players, fn(x) -> update_player(x) end)
        end

      # Clean players with less than zero health.
      players()
      |> Enum.filter(fn {_, player} -> player.state.health <= 0 end)
      |> Enum.map(fn {_, player} -> Player.handle_action(player, "death") |> update_player() end)

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
        updated_player |> update_player()
      else
        # Update player.
        updated_player |> update_player()
      end
    end)
  end
end
