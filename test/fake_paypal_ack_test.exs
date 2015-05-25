defmodule FakePaypalAckTest do
  use ExUnit.Case, async: true

  test "response" do
    assert("VERIFIED" == Ipn.FakePaypalAck.response("foo"))
  end

end
