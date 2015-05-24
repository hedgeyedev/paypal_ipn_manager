defmodule DatabaseWorkerTest do
  use ExUnit.Case, async: false

  setup do
    {:ok, worker} = Ipn.DatabaseWorker.start_link("./test_persist", 1)

    on_exit(fn ->
      File.rm_rf("./test_persist/")
      send(worker, :stop)
    end)

    {:ok, worker: worker}
  end

  test "get and store" do
    assert(nil == Ipn.DatabaseWorker.get(1, 1))

    Ipn.DatabaseWorker.store(1, 1, {:some, "data"})
    Ipn.DatabaseWorker.store(1, 2, {:another, ["data"]})

    assert({:some, "data"} == Ipn.DatabaseWorker.get(1, 1))
    assert({:another, ["data"]} == Ipn.DatabaseWorker.get(1, 2))
  end
end
