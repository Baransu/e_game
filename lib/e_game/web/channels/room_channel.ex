defmodule EGame.Web.RoomChannel do
  use Phoenix.Channel

  alias EGame.Presence
  alias EGame.PersistentRoom

  def push_locations(socket, msg) do
    push(socket, "push:image", msg)
  end

  def join("room:lobby", _message, socket) do
    messages = PersistentRoom.get_all()
    send(self(), :after_join)
    {:ok, %{messages: messages}, socket}
  end
  def join(_room, _params, _socket) do
    {:error, %{reason: "You can only join the lobby"}}
  end

  def handle_in("new:msg", message_body, socket) do
    # sample location push to test if everythig works
    PersistentRoom.put(message_body)
    %{id: id, region: region } = socket.assigns
    %{"body" => body, "user" => user} = message_body
    EGame.Region.Worker.update_position(region, %{"id" => id}, {body, user})
    broadcast!(socket, "new:msg", message_body)
    {:noreply, socket}
  end

  def handle_info(:after_join, socket) do
    id = socket.assigns[:id]
    { region } = EGame.Region.Pool.assign_region();
    EGame.Notifier.add_socket(id, socket)
    {:ok, _} = Presence.track(socket, id, %{})
    {:noreply, assign(socket, :region, region)}
  end

end
