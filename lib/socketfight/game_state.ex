defmodule Socketfight.GameState do
  use Agent

  # @arena_width 1080
  # @arena_height 720

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
  Get all the players in the map
  """
  def players do
    Agent.get(__MODULE__, & &1)
  end

  def update_player_action(player_id, action, state) do
    player_id
    |> get_player
    |> update_player_meta(action, state)
    |> update_player
  end

  def update_player_meta(player, key, value) do
    player
    |> put_in([:actions, key], value)

    # |> Map.update!(key, fn(_) -> value end)
  end

  @doc """
  Calculate game tick.
  """
  def tick() do
    # Using parens in `players()` to avoid ambiguity between a function call
    # and a variable that could also be named (and look like) `players`
    Enum.each(players(), fn {_key, player} ->
      # Only consider actions that have a value of `true`.
      #
      # With the current implementation of player.actions, this is a list
      # of strings in the format such as: ["forward", "right"]. Technically
      # we wouldn't need to trim out the keys, but.. whatever, feels nice :)
      taken_actions =
        player.actions
        |> Enum.filter(fn {_action_key, action_value} -> action_value == true end)
        |> Enum.map(fn {action_key, _action_value} -> action_key end)

      # Now that we know exactly what actions have been taken, we can avoid
      # checking for their value from here on. This means we can now just
      # loop through the remaining actions with `Enum.reduce`
      updated_player =
        Enum.reduce(taken_actions, player, fn action, acc ->
          player_handle(acc, action)
        end)

      # NOTE: We could remove ALL variables here and just |> pipe ourselves
      # from start to finish. Leaving some named variables here for clarity :)
      updated_player
      |> update_player()
    end)
  end

  # Using the same function name but a different head for each allows us to
  # just call a single function with a given action in the reduction loop.
  # Note that we now also avoid needing to check if given `action`
  def player_handle(player, "forward") do
    xOffset = :math.cos(player.state.rotation + :math.pi() / 2) * 5
    yOffset = :math.sin(player.state.rotation + :math.pi() / 2) * 5
    player = update_in(player, [:state, :x], fn x -> x - xOffset end)
    update_in(player, [:state, :y], fn y -> y - yOffset end)
  end

  def player_handle(player, "left") do
    update_in(player, [:state, :rotation], fn rotation -> rotation - :math.pi() / 60 end)
  end

  def player_handle(player, "right") do
    update_in(player, [:state, :rotation], fn rotation -> rotation + :math.pi() / 60 end)
  end

  # Maybe not what we need, but it's good practice to handle these too
  def player_handle(_player, _other) do
    {:error, "Invalid action"}
  end
end
