defmodule Ipn.Server do
  use GenServer

  def start_link(name) do
    IO.puts "Starting ipn server for #{name}"
    GenServer.start_link(Ipn.Server, name, name: via_tuple(name))
  end

  def add_entry(ipn_server, new_entry) do
    GenServer.cast(ipn_server, {:add_entry, new_entry})
  end

  def entries(ipn_server, date) do
    GenServer.call(ipn_server, {:entries, date})
  end

  def update_entry(ipn_server, entry_id, updater_fun) do
    GenServer.cast(ipn_server, {:update_entry, entry_id, updater_fun})
  end

  def delete_entry(ipn_server, entry_id) do
    GenServer.cast(ipn_server, {:delete_entry, entry_id})
  end

  def whereis(name) do
    :gproc.whereis_name({:n, :l, {:ipn_server, name}})
  end

  defp via_tuple(name) do
    {:via, :gproc, {:n, :l, {:ipn_server, name}}}
  end

  def init(name) do
    {:ok, {name, Ipn.Database.get(name) || Ipn.List.new}}
  end


  def handle_cast({:add_entry, new_entry}, {name, ipn_list}) do
    new_state = Ipn.List.add_entry(ipn_list, new_entry)
    Ipn.Database.store(name, new_state)
    {:noreply, {name, new_state}}
  end

  def handle_cast({:update_entry, entry_id, updater_fun}, {name, ipn_list}) do
    new_state = Ipn.List.update_entry(ipn_list, entry_id, updater_fun)
    Ipn.Database.store(name, new_state)
    {:noreply, {name, new_state}}
  end

  def handle_cast({:delete_entry, entry_id}, {name, ipn_list}) do
    new_state = Ipn.List.delete_entry(ipn_list, entry_id)
    Ipn.Database.store(name, new_state)
    {:noreply, {name, new_state}}
  end


  def handle_call({:entries, date}, _, {name, ipn_list}) do
    {
      :reply,
      Ipn.List.entries(ipn_list, date),
      {name, ipn_list}
    }
  end

  # Needed for testing purposes
  def handle_info(:stop, state), do: {:stop, :normal, state}
  def handle_info(_, state), do: {:noreply, state}
end
