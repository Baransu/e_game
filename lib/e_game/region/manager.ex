defmodule EGame.Region.Manager do
  @moduledoc "Manages regions and player interaction with regions"

  use GenServer

  alias EGame.Region

  @regions_count 15

  ### CLIENT API

  def start_link() do
    GenServer.start_link(__MODULE__, create_regions(), name: __MODULE__)
  end

  # TODO: attach region to user -> region pid
  # TODO: push all locations to user
  # TODO: handle user transition to another region
  # TODO: handle user logout

  ### SERVER API

  def init(regions), do: {:ok, regions}

  ### HELPER FUNCTIONS

  defp create_regions() do
    # We should load files from file system here and then start
    # but for now we'll create regions from hardcoded list

    range = 0..@regions_count - 1
    Enum.map(range, &create_region/1)
  end

  defp create_region(_) do
    {:ok, pid} = Region.Supervisor.spawn_region()
    # We should return more than pid like size, and stuff like that
    # all things helping us find correct region for user, move regions etc
    pid
  end

end
