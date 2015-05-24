defmodule Ipn.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, nil)
  end

  def init(_) do
    processes = [
      supervisor(Ipn.Database, ["./persist/"]),
      supervisor(Ipn.ServerSupervisor, []),
      worker(Ipn.Cache, [])
    ]
    supervise(processes, strategy: :one_for_one)
  end
end
