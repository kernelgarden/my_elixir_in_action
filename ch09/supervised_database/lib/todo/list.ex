defmodule Todo.List do
  defstruct auto_id: 1, entries: %{}

  def new(), do: %Todo.List{}

  def new(entries \\ []) do
    Enum.reduce(entries,
      %Todo.List{},
      fn entry, todo_list_acc -> add_entry(todo_list_acc, entry) end)
  end

  def add_entry(todo_list, entry) do
    # 새로운 entry에 id 부여
    entry = Map.put(entry, :id, todo_list.auto_id)

    # 새로운 엔트리 맵 생성
    new_entries = Map.put(todo_list.entries,
      todo_list.auto_id,
      entry)

    # struct 업데이트
    %Todo.List{todo_list |
      entries: new_entries,
      auto_id: todo_list.auto_id + 1}
  end

  def entries(todo_list, date) do
    # iterate whole map once
    todo_list.entries
    |> Stream.filter(fn {_, entry} -> entry.date == date end)
    |> Enum.map(fn {_, entry} -> entry end)
  end

  def update_entry(todo_list, entry_id, updater_fun) do
    case Map.fetch(todo_list.entries, entry_id) do
      :error ->
        IO.puts("cannot find id - #{entry_id} !!!")
        todo_list

      {:ok, old_entry} ->
        # pin operator로 id를 고정시킨다.
        old_entry_id = old_entry.id
        new_entry = %{id: ^old_entry_id} = updater_fun.(old_entry)
        new_entries = Map.put(todo_list.entries, entry_id, new_entry)
        %Todo.List{todo_list | entries: new_entries}
    end
  end

  def update_entry(todo_list, %{} = new_entry) do
    update_entry(todo_list, new_entry.id, fn _ -> new_entry end)
  end

  def delete_entry(todo_list, entry_id) do
    new_entries = Map.delete(todo_list.entries, entry_id)
    %Todo.List{todo_list | entries: new_entries}
  end
end

defimpl Collectable, for: Todo.List do
  def into(original) do
    {original, &into_callback/2}
  end

  defp into_callback(todo_list, {:cont, entry}) do
    Todo.List.add_entry(todo_list, entry)
  end
  defp into_callback(todo_list, :done), do: todo_list
  defp into_callback(todo_list, :halt), do: :ok
end
