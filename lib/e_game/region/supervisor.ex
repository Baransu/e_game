defmodule EGame.Region.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def spawn_region() do
    Supervisor.start_child(__MODULE__, [])
  end

  def init(:ok) do
    children = [
      worker(EGame.Region.Worker, [])
    ]

    opts = [strategy: :simple_one_for_one]
    supervise(children, opts)
  end

end
