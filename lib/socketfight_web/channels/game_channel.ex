# https://medium.com/@miguel.coba/building-a-game-with-phoenix-channels-a3e6b390cfcc

defmodule SocketfightWeb.GameChannel do
  use Phoenix.Channel
  alias Socketfight.GameState
  alias Socketfight.Player

  def join("game:default", message, socket) do
    # Notify self.
    send(self(), {:after_join, message})
    {:ok, socket}
  end

  def join("game:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  # Add new player to players list.
  def handle_info({:after_join, _message}, socket) do
    # Create unique id for each joined player.
    player_id = UUID.uuid1()

    # Submit a map to players.
    broadcast!(socket, "player:join", %{obstacles: GameState.obstacles()})

    {:noreply, assign(socket, :player_id, player_id)}
  end

  def handle_in("join", %{}, socket) do
    # Create new player and add it to the game
    socket.assigns.player_id
    |> Player.new()
    |> GameState.put_player()

    {:noreply, socket}
  end

  def handle_in("event", %{"action" => action, "state" => state}, socket) do
    player_id = socket.assigns.player_id
    GameState.update_player_action(player_id, action, state)
    {:noreply, socket}
  end
end
