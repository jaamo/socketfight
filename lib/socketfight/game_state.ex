defmodule Socketfight.GameState do
  use Agent

  @arena_width 1080
  @arena_height 720

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

  def enable_player_state(player_id, action) do 
    player_id 
    |> get_player 
    |> update_player_meta(:forward, true) 
    |> update_player
  end

  def update_player_meta(player, key, value) do
    player
    |> Map.update!(key, fn(a) -> value end)
  end

end
