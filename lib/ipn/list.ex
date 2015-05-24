defmodule Ipn.List do
  defstruct auto_id: 1, entries: HashDict.new

  def new(entries \\ []) do
    Enum.reduce(
      entries,
      %Ipn.List{},
      &add_entry(&2, &1)
    )
  end

  def size(ipn_list) do
    HashDict.size(ipn_list.entries)
  end

  def add_entry(
    %Ipn.List{entries: entries, auto_id: auto_id} = ipn_list,
    entry
  ) do
    entry = Map.put(entry, :id, auto_id)
    new_entries = HashDict.put(entries, auto_id, entry)

    %Ipn.List{ipn_list |
      entries: new_entries,
      auto_id: auto_id + 1
    }
  end

  def entries(%Ipn.List{entries: entries}, date) do
    entries
    |> Stream.filter(fn({_, entry}) ->
         entry.date == date
       end)

    |> Enum.map(fn({_, entry}) ->
         entry
       end)
  end


  def update_entry(ipn_list, %{} = new_entry) do
    update_entry(ipn_list, new_entry.id, fn(_) -> new_entry end)
  end

  def update_entry(
    %Ipn.List{entries: entries} = ipn_list,
    entry_id,
    updater_fun
  ) do
    case entries[entry_id] do
      nil -> ipn_list

      old_entry ->
        new_entry = updater_fun.(old_entry)
        new_entries = HashDict.put(entries, new_entry.id, new_entry)
        %Ipn.List{ipn_list | entries: new_entries}
    end
  end


  def delete_entry(
    %Ipn.List{entries: entries} = ipn_list,
    entry_id
  ) do
    %Ipn.List{ipn_list | entries: HashDict.delete(entries, entry_id)}
  end
end
