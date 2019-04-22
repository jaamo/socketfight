# https://medium.com/@miguel.coba/building-a-game-with-phoenix-channels-a3e6b390cfcc

defmodule SocketfightWeb.GameChannel do
  use Phoenix.Channel
  alias Socketfight.GameState

  def join("game:default", message, socket) do

    # Get all players.
    players = GameState.players()

    # Notify self.
    send(self, {:after_join, message})

    # Return players list to the client.
    #{:ok, %{players: players}, socket}
    {:ok, socket}

  end

  def join("game:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  # Add new player to players list.
  def handle_info({:after_join, _message}, socket) do

    # Create unique id for each joined player.
    player_id = UUID.uuid1()

    # Create new player
    player = %{
      id: player_id, 
      actions: %{
        "forward" => false,
        "left" => false,
        "right" => false,
        "brake" => false
      },
      state: %{
        x: 540, 
        y: 360,
        rotation: 0.0
      }
    }

    # Add player to the game.
    player = GameState.put_player(player)

    # Notify that new player joined
    # broadcast! socket, "player:join", %{player: player}
    {:noreply, assign(socket, :player_id, player_id)}
       
  end

  def handle_in("event", %{"action" => action, "state" => state}, socket) do
    player_id = socket.assigns.player_id
    #player_id = 1
    player = GameState.update_player_action(player_id, action, state)
    #broadcast! socket, "player:update", %{player: player}
    {:noreply, socket}
  end

  # old this kept as reference
  """
  def handle_in("new_msg", %{"body" => body}, socket) do
    broadcast!(socket, "new_msg", %{body: body})
    {:noreply, socket}
  end
  """


end
