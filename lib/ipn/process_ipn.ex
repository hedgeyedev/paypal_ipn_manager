defmodule Ipn.ProcessIpn do
  use GenServer

  def start_link(ipn) do
    paypal_id = extract_paypal_id(ipn)
    IO.puts "Starting ipn processing server for #{paypal_id}"
    GenServer.start_link(Ipn.ProcessIpn, ipn, name: via_tuple(paypal_id))
  end

  def transfer(process_server, ipn) do
    GenServer.cast(process_server, {:transfer, ipn})
  end

  def whereis(paypal_id) do
    :gproc.whereis_name({:n, :l, {:transfer, paypal_id}})
  end

  defp via_tuple(paypal_id) do
    {:via, :gproc, {:n, :l, {:transfer, paypal_id}}}
  end

end
