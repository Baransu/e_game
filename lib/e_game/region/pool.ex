defmodule EGame.Region.Pool do
  @moduledoc "Manages regions and player interaction with regions"

  use GenServer

  alias EGame.Region

  @world_size 100
  @region_size 20

  ### CLIENT API

  def start_link() do
    GenServer.start_link(__MODULE__, create_regions(), name: __MODULE__)
  end

  def assign_region() do
    GenServer.call(__MODULE__, :assign_region)
  end

  def push_image(socket) do
    GenServer.cast(__MODULE__, {:push_image, socket})
  end

  # TODO: handle region death (restart only failed region)
  # TODO: handle user transition to another region

  ### SERVER API

  def init(regions), do: {:ok, regions}

  def handle_cast({:push_image, socket}, state) do
    # TODO: get regions attached to socket
    # socket.assigns[:region]
    # right now we're pushing from all regions
    Enum.map(state, &push_region_image(socket, &1))
    {:noreply, state}
  end

  def handle_call(:assign_region, _from, state) do
    # TODO: real test based on user position
    [{pid, _, _} | _] = state
    # assign 8 smaller regions as neighbours
    {:reply, {pid}, state}
  end

  ### HELPER FUNCTIONS

  defp push_region_image(socket, {region_pid, _x, _y}) do
    Region.Worker.push_image(region_pid, socket);
  end

  defp create_regions() do
    # We should load files from file system here and then start
    # but for now we'll create regions from hardcoded list
    range = 0..div(@world_size, @region_size)
    regions =
      Enum.map(range, fn y -> Enum.map(range, &create_region(&1, y)) end)
      |> List.flatten
    IO.inspect regions
    regions
  end

  defp create_region(x, y) do
    # TODO: We will have to pass x and y to region
    {:ok, pid} = Region.Supervisor.spawn_region()
    # We should return more than pid like size, and stuff like that
    # all things helping us find correct region for user, move regions etc
    {pid, x * @region_size, y * @region_size}
  end

end
