defmodule Socketfight.Player do
  alias Socketfight.CollisionDetector

  @moduledoc """
  This module contains functions to interact with representations of players.
  The functions in this module are meant to transform player-related data,
  but they should not know anything about how the game is actually run.
  """

  @doc """
  Create a new data representation of a player. `player_id` is expected
  to be an unique string identifier for the player.
  """
  @spec new(String.t()) :: map()
  def new(player_id) when is_binary(player_id) do
    %{
      id: player_id,
      radius: 20,
      actions: %{
        forward: false,
        left: false,
        right: false,
        brake: false,
        shoot: false
      },
      state: %{
        x: 540,
        y: 360,
        newX: 540,
        newY: 360,
        collision: false,
        rotation: 0.0,
        shootCooldown: 0,
        shootTargetX: 0,
        shootTargetY: 0,
        shot: false,
        health: 100,
        kills: 0,
        deaths: 0
      }
    }
  end

  def new(_player_id), do: {:error, "player_id not a string"}

  @doc """
  If player dies, increase death counter and reset health.
  """
  def handle_action(player, "death") do
    player
    |> update_in([:state, :health], fn _ -> 100 end)
    |> update_in([:state, :deaths], fn deaths -> deaths + 1 end)
  end

  @doc """
  Handle player moving forward.
  """
  def handle_action(player, "forward") do
    xOffset = :math.cos(player.state.rotation + :math.pi() / 2) * 5
    yOffset = :math.sin(player.state.rotation + :math.pi() / 2) * 5
    player = update_in(player, [:state, :newX], fn _ -> player.state.x - xOffset end)
    update_in(player, [:state, :newY], fn _ -> player.state.y - yOffset end)
  end

  @doc """
  Handle player moving backwards.
  """
  def handle_action(player, "brake") do
    xOffset = :math.cos(player.state.rotation + :math.pi() / 2) * 5
    yOffset = :math.sin(player.state.rotation + :math.pi() / 2) * 5
    player = update_in(player, [:state, :newX], fn x -> x + xOffset end)
    update_in(player, [:state, :newY], fn y -> y + yOffset end)
  end

  @doc """
  Handle player moving left.
  """
  def handle_action(player, "left") do
    update_in(player, [:state, :rotation], fn rotation -> rotation - :math.pi() / 60 end)
  end

  @doc """
  Handle player moving right.
  """
  def handle_action(player, "right") do
    update_in(player, [:state, :rotation], fn rotation -> rotation + :math.pi() / 60 end)
  end

  @doc """
  Handle player shooting.
  """
  def handle_action(player, "shoot") do
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

  @doc """
  Handle shoot cooldown for a player.
  """
  def handle_shoot_cooldown(player) do
    cond do
      player.state.shootCooldown > 0 ->
        update_in(player, [:state, :shootCooldown], fn shootCooldown -> shootCooldown - 1 end)

      true ->
        player
    end
  end

  @doc """
  Reset player collision state.
  """
  def reset_collision(player) do
    update_in(player, [:state, :collision], fn _ -> false end)
  end

  @doc """
  Reset player shot state.
  """
  def reset_shot_state(player) do
    update_in(player, [:state, :shot], fn _ -> false end)
  end

  @doc """
  Check if player has shot and deal damage to players hit by bullet. Returns
  a player with updated kills status.
  """
  @spec deal_damage(map(), list(), boolean()) :: list()
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
    end)
  end

  @doc """
  In case weapon is not shot, no damage is done.
  """
  def deal_damage(player, _, _) do
    player
  end

  # def handle_bullet_damage(player, players) do
  # end
end
