defmodule IpnCacheTest do
  use ExUnit.Case, async: false

  setup do
    :meck.new(Ipn.Database, [:no_link])
    :meck.expect(Ipn.Database, :start_link, fn(_) -> nil end)
    :meck.expect(Ipn.Database, :get, fn(_) -> nil end)
    :meck.expect(Ipn.Database, :store, fn(_, _) -> :ok end)
    on_exit(fn ->
      :meck.unload(Ipn.Database)
    end)
  end

  test "server_process" do
    Ipn.ServerSupervisor.start_link
    Ipn.Cache.start_link
    bobs_list = Ipn.Cache.server_process("bobs_list")
    alices_list = Ipn.Cache.server_process("alices_list")

    assert(bobs_list != alices_list)
    assert(bobs_list == Ipn.Cache.server_process("bobs_list"))

    Process.exit(Process.whereis(:ipn_server_supervisor), :normal)
  end
end
