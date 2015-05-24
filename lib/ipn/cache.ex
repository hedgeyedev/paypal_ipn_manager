defmodule Ipn.Cache do
  use GenServer

  def start_link do
    IO.puts "Starting ipn cache."

    GenServer.start_link(__MODULE__, nil, name: :ipn_cache)
  end

  def server_process(ipn_list_name) do
    case Ipn.Server.whereis(ipn_list_name) do
      :undefined ->
        GenServer.call(:ipn_cache, {:server_process, ipn_list_name})
      pid -> pid
    end
  end

  def init(_) do
    {:ok, nil}
  end

  def handle_call({:server_process, ipn_list_name}, _, state) do
    ipn_server_pid = case Ipn.Server.whereis(ipn_list_name) do
      :undefined ->
        {:ok, pid} = Ipn.ServerSupervisor.start_child(ipn_list_name)
        pid

      pid -> pid
    end
    {:reply, ipn_server_pid, state}
  end
end
