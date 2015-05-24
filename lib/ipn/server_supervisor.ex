defmodule Ipn.ServerSupervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, nil, name: :ipn_server_supervisor)
  end

  def start_child(ipn_list_name) do
    Supervisor.start_child(:ipn_server_supervisor, [ipn_list_name])
  end

  def init(_) do
    supervise([worker(Ipn.Server, [])], strategy: :simple_one_for_one)
  end
end
