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
  def push_image(pid, socket) do
    GenServer.cast(pid, {:push_image, socket})
  end

  @doc "Connects player to specific region"
  def connect(pid, player) do
    GenServer.cast(pid, {:connect, player})
  end

  @doc "Removes player from state"
  def disconnect(pid, player) do
    GenServer.cast(pid, {:disconnect, player})
  end

  # SERVER API

  def init(_) do
    # here we should probably ask DB for backup info
    # to have correct state after crash
    {:ok, %{}}
  end

  def handle_cast({:update_position, %{"id" => id}, position}, players) do
    updated_players = Map.put(players, id, %{"position" => position})
    # If user will leave region, we have to notify EGame.Region.Manager about that
    # it will provide smooth transition between regions
    {:noreply, updated_players}
  end

  def handle_cast({:push_image, socket}, players) do
    # Stored user should be more than x and y postion in world but
    # right now we're focusing only on players cordinates
    locations = Enum.map(players, &get_location/1)
    EGame.Web.RoomChannel.push_locations(socket, %{locations: locations})
    # IO.inspect locations
    {:noreply, players}
  end

  def handle_cast({:disconnect, %{"id" => id}}, players) do
    updated_players = Map.delete(players, id)
    {:noreply, updated_players}
  end

  ### HELPER FUNCTONS

  # Returns location map
  defp get_location({_, %{"position" => {x, y}}}) do
    %{"x" => x, "y" => y}
  end
end
