defmodule EGame.Region.Worker do
  @moduledoc "Worker managing certain region in game world"

  use GenServer

  # CLIENT API

  def start_link() do
    GenServer.start_link(__MODULE__, [])
  end

  @doc "Updates player position in state"
  def update_position(pid, player, position) do
    GenServer.cast(pid, {:update_position, player, position})
  end

  @doc "Pushes all stored players positions to socket"
  def push_all(pid, socket) do
    GenServer.cast(pid, {:push_all, socket})
  end

  @doc "Connects player to specific region"
  def connect(pid, player) do
    GenServer.cast(pid, {:connect, player})
  end

  @doc "Removes player from state"
  def disconnect(pid, player) do
    GenServer.cast(pid, {:dicconnect, player})
  end

  # SERVER API

  def init(_) do
    # here we should probably as DB for locations
    # to have correct state after crash
    {:ok, {:ok, %{}}}
  end

  def handle_cast({:update_position, %{"id" => id}, position}, {sup_pid, players}) do
    updated_players = Map.put(players, id, position)
    # If user will leave region, we have to notify EGame.Region.Manager about that
    # it will provide smooth transition between regions
    {:noreply, {sup_pid, updated_players}}
  end

  def handle_cast({:push_all, _socket}, state) do
    # Stored user should be more than x and y postion in world but
    # right now we're focusing only on players cordinates
    {_, players} = state
    locations = Enum.map(players, &get_location/1)
    # push all to passed socket
    IO.inspect locations
    {:noreply, state}
  end

  def handle_cast({:disconnect, %{"id" => id}}, {sup_pid, players}) do
    updated_players = Map.delete(players, id)
    {:noreply, {sup_pid, updated_players}}
  end

  ### HELPER FUNCTONS

  # Returns location map
  defp get_location(%{"position" => {x, y}}) do
    %{"x" => x, "y" => y}
  end
end
