defmodule DatabaseServerTest do
  use ExUnit.Case, async: false

  setup do
    :meck.new(Ipn.DatabaseWorker, [:no_link])
    :meck.expect(Ipn.DatabaseWorker, :start_link, &MockIpn.DatabaseWorker.start/2)
    :meck.expect(Ipn.DatabaseWorker, :store, &MockIpn.DatabaseWorker.store/3)
    :meck.expect(Ipn.DatabaseWorker, :get, &MockIpn.DatabaseWorker.get/2)
    Ipn.Database.start_link("./test_persist")

    on_exit(fn ->
      File.rm_rf("./test_persist/")
      :meck.unload(Ipn.DatabaseWorker)
    end)
  end

  test "pooling" do
    assert(Ipn.Database.store(1, :a) == Ipn.Database.store(1, :a))
    assert(Ipn.Database.get(1) == Ipn.Database.store(1, :a))
    assert(Ipn.Database.store(2, :a) != Ipn.Database.store(1, :a))
  end
end

defmodule MockIpn.DatabaseWorker do
  use GenServer

  def start(_, worker_id) do
    GenServer.start(__MODULE__, nil, name: worker_alias(worker_id))
  end

  def store(worker_id, key, data) do
    GenServer.call(worker_alias(worker_id), {:store, key, data})
  end

  def get(worker_id, key) do
    GenServer.call(worker_alias(worker_id), {:get, key})
  end

  defp worker_alias(worker_id) do
    :"database_worker_#{worker_id}"
  end


  def init(state) do
    {:ok, state}
  end

  def handle_call({:store, _, _}, _, state) do
    {:reply, self, state}
  end

  def handle_call({:get, _}, _, state) do
    {:reply, self, state}
  end

  # Needed for testing purposes
  def handle_info(:stop, state), do: {:stop, :normal, state}
  def handle_info(_, state), do: {:noreply, state}
end
