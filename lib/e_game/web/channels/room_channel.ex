defmodule EGame.Web.RoomChannel do
  use Phoenix.Channel

  alias EGame.PersistentRoom

  def join("room:lobby", _message, socket) do
    messages = PersistentRoom.get_all()
    {:ok, %{messages: messages}, socket}
  end
  def join(_room, _params, _socket) do
    {:error, %{reason: "You can only join the lobby"}}
  end

  def handle_in("new:msg", message_body, socket) do
    # forward message do everyone in the room
    PersistentRoom.put(message_body)
    broadcast!(socket, "new:msg", message_body)
    {:noreply, socket}
  end
end
