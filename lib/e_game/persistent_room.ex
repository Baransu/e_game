defmodule EGame.PersistentRoom do

  @doc "Starts new PersistentRoom storage"
  def start_link do
    # state of this Agent is list of typles {:user, :msg}
    Agent.start_link(fn -> [] end, name: __MODULE__)
  end

  @doc "Put single message"
  def put(message) do
    Agent.update(__MODULE__, fn state -> [message | state] end)
  end

  @doc "Get all stored messages"
  def get_all() do
    Agent.get(__MODULE__, fn list -> Enum.reverse(list) end)
  end
end
