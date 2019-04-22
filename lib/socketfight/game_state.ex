defmodule Socketfight.GameState do
  use Agent

  #@arena_width 1080
  #@arena_height 720

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
    Agent.get(__MODULE__, &(&1))
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
    #|> Map.update!(key, fn(_) -> value end)
  end

  @doc """
  Calculate game tick.
  """
  def tick() do
    Enum.each players, fn{key, player} ->
      player_tick(player)
    end     
  end

  def player_tick(player) do
    if player.actions["forward"] do 
      xOffset = :math.cos(player.state.rotation + :math.pi() / 2) * 5
      yOffset = :math.sin(player.state.rotation + :math.pi() / 2) * 5
      player = update_in(player, [:state, :x], fn(x) -> x - xOffset end)
      update_player(player)
      player = update_in(player, [:state, :y], fn(y) -> y - yOffset end)
      update_player(player)
    end
    if player.actions["brake"] do 
    end
    if player.actions["left"] do 
      player = update_in(player, [:state, :rotation], fn(rotation) -> rotation - :math.pi() / 60 end)
      update_player(player)
    end
    if player.actions["right"] do 
      player = update_in(player, [:state, :rotation], fn(rotation) -> rotation + :math.pi() / 60 end)
      update_player(player)
    end
  end

end
