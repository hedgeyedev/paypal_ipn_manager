defmodule IpnServerTest do
  use ExUnit.Case, async: false

  setup do
    :meck.new(Ipn.Database, [:no_link])
    :meck.expect(Ipn.Database, :get, fn(_) -> nil end)
    :meck.expect(Ipn.Database, :store, fn(_, _) -> :ok end)

    {:ok, ipn_server} = Ipn.Server.start_link("test_list")

    on_exit(fn ->
      :meck.unload(Ipn.Database)
      send(ipn_server, :stop)
    end)

    {:ok, ipn_server: ipn_server}
  end


  test "add_entry", context do
    assert([] == Ipn.Server.entries(context[:ipn_server], {2013, 12, 19}))

    Ipn.Server.add_entry(context[:ipn_server], %{date: {2013, 12, 19}, title: "Dentist"})
    assert(1 == Ipn.Server.entries(context[:ipn_server], {2013, 12, 19}) |> length)
    assert("Dentist" == (Ipn.Server.entries(context[:ipn_server], {2013, 12, 19}) |> Enum.at(0)).title)
  end

  test "update_entry", context do
    Ipn.Server.add_entry(context[:ipn_server], %{date: {2013, 12, 19}, title: "Dentist"})
    Ipn.Server.update_entry(context[:ipn_server], 1, &Map.put(&1, :title, "Updated dentist"))
    assert("Updated dentist" == (Ipn.Server.entries(context[:ipn_server], {2013, 12, 19}) |> Enum.at(0)).title)
  end

  test "delete_entry", context do
    Ipn.Server.add_entry(context[:ipn_server], %{date: {2013, 12, 19}, title: "Dentist"})
    Ipn.Server.delete_entry(context[:ipn_server], 1)
    assert([] == Ipn.Server.entries(context[:ipn_server], {2013, 12, 19}))
  end
end
