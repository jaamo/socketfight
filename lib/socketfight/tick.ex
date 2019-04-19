defmodule Socketfight.Tick do
  use GenServer
  alias Socketfight.GameState
  
  def start_link(_) do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    schedule_work() # Schedule work to be performed on start
    {:ok, state}
  end

  def handle_info(:work, state) do
    # Do the desired work here
    schedule_work() # Reschedule once more
    player = GameState.get_player(1)
    if player != nil do
      IO.puts "Player: #{player.forward}"
    end
    {:noreply, state}
  end

  defp schedule_work() do
    Process.send_after(self(), :work, 1000)
  end
end
