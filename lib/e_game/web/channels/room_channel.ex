defmodule EGame.Web.RoomChannel do
  use Phoenix.Channel

  def join("room:lobby", _message, socket) do
    {:ok, socket}
  end
  def join(_room, _params, _socket) do
    {:error, %{reason: "You can only join the lobby"}}
  end

  def handle_in("new:msg", body, socket) do
    # forward message do everyone in the room
    broadcast!(socket, "new:msg", body)
    {:noreply, socket}
  end

end
