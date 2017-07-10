defmodule EGame.Notifier do
  use GenServer

  alias EGame.Presence

  @name EGame.Notifier
  @push_delay 100
  @clean_delay 5000

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: @name)
  end

  def add_socket(id, socket) do
    GenServer.cast(@name, {:add_socket, id, socket})
  end

  def init([]) do
    push_notify()
    clean_notify()
    {:ok, %{}}
  end

  def handle_cast({:add_socket, id, socket}, state) do
    {:noreply, Map.put(state, id, socket)}
  end

  def handle_info(:push_image, state) do
    Map.take(state, get_keys())
    |> Enum.map(fn {_, socket} -> EGame.Region.Pool.push_image(socket) end)
    push_notify()
    {:noreply, state}
  end

  def handle_info(:clean, state) do
    to_delete = Map.keys(state) -- get_keys()
    new_state = Map.drop(state, to_delete)
    clean_notify()
    {:noreply, new_state}
  end

  defp get_keys do
    Presence.list("room:lobby") |> Enum.map(fn {key, _} -> key end)
  end

  defp push_notify do
    :timer.send_after(@push_delay, self(), :push_image)
  end

  defp clean_notify do
    :timer.send_after(@clean_delay, self(), :clean)
  end

end
