defmodule IpnListTest do
  use ExUnit.Case, async: true

  test "empty list" do
    assert(0 == Ipn.List.size(Ipn.List.new))
  end

  test "add_entry" do
    assert(3 == Ipn.List.size(sample_ipn_list))
    assert(2 == sample_ipn_list |> Ipn.List.entries({2013, 12, 19}) |> length)
    assert(1 == sample_ipn_list |> Ipn.List.entries({2013, 12, 20}) |> length)
    assert(0 == sample_ipn_list |> Ipn.List.entries({2013, 12, 22}) |> length)

    assert(2 == shopping_entry.id)
    assert({2013, 12, 20} == shopping_entry.date)
    assert("Shopping" == shopping_entry.title)
  end

  test "update_entry" do
    updated_list =
      sample_ipn_list
      |> Ipn.List.update_entry(shopping_entry.id, &Map.put(&1, :title, "Updated shopping"))

    assert(3 == Ipn.List.size(updated_list))
    assert("Updated shopping" == shopping_entry(updated_list).title)


    not_modified_list =
      sample_ipn_list
      |> Ipn.List.update_entry(-1, fn(_) -> flunk("shouldn't happen") end)

    assert(sample_ipn_list == not_modified_list)
  end

  test "delete_entry" do
    deleted_list = Ipn.List.delete_entry(sample_ipn_list, shopping_entry.id)

    assert(2 == Ipn.List.size(deleted_list))
    assert(0 == deleted_list |> Ipn.List.entries({2013, 12, 20}) |> length)
  end

  defp sample_ipn_list do
    Ipn.List.new
    |> Ipn.List.add_entry(%{date: {2013, 12, 19}, title: "Dentist"})
    |> Ipn.List.add_entry(%{date: {2013, 12, 20}, title: "Shopping"})
    |> Ipn.List.add_entry(%{date: {2013, 12, 19}, title: "Movies"})
  end

  defp shopping_entry(ipn_list \\ sample_ipn_list) do
    ipn_list
    |> Ipn.List.entries({2013, 12, 20})
    |> Enum.at(0)
  end
end
