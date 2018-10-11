defmodule TodoServer do
  def init() do
    TodoList.new()
  end

  def add_entry(server_pid, entry) do
    ServerProcess.cast(server_pid, {:add, entry})
  end

  def update_entry(server_pid, entry_id, updater_fun) do
    ServerProcess.cast(server_pid, {:update, entry_id, updater_fun})
  end

  def update_entry(server_pid, %{} = new_entry) do
    ServerProcess.cast(server_pid, {:update, new_entry})
  end

  def delete_entry(server_pid, entry_id) do
    ServerProcess.cast(server_pid, {:delete, entry_id})
  end

  def entries(server_pid, date) do
    ServerProcess.call(server_pid, {:gets, date})
  end


  def handle_call({:gets, date}, cur_todo_list) do
    {TodoList.entries(cur_todo_list, date), cur_todo_list}
  end

  def handle_cast({:add, entry}, cur_todo_list) do
    TodoList.add_entry(cur_todo_list, entry)
  end
  def handle_cast({:update, entry_id, updater_fun}, cur_todo_list) do
    TodoList.update_entry(cur_todo_list, entry_id, updater_fun)
  end
  def handle_cast({:update, %{} = new_entry}, cur_todo_list) do
    TodoList.update_entry(cur_todo_list, new_entry)
  end
  def handle_cast({:delete, entry_id}, cur_todo_list) do
    TodoList.delete_entry(cur_todo_list, entry_id)
  end
end


defmodule TodoList do
  defstruct auto_id: 1, entries: %{}

  def new(), do: %TodoList{}

  def new(entries \\ []) do
    Enum.reduce(entries,
      %TodoList{},
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
    %TodoList{todo_list |
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
        %TodoList{todo_list | entries: new_entries}
    end
  end

  def update_entry(todo_list, %{} = new_entry) do
    update_entry(todo_list, new_entry.id, fn _ -> new_entry end)
  end

  def delete_entry(todo_list, entry_id) do
    new_entries = Map.delete(todo_list.entries, entry_id)
    %TodoList{todo_list | entries: new_entries}
  end
end

defmodule TodoList.CsvImporter do

  def get_test_path(), do: Path.expand('dummy.csv') |> Path.absname()

  def import(path) do
    read_csv(path)
  end

  defp read_csv(path) do
    entities = File.stream!(path)
    |> Stream.map(&String.replace(&1, "\n", ""))
    |> Enum.map(fn line -> transform_to_entry(parse_line(line)) end)

    TodoList.new(entities)
  end

  defp parse_line(line) do
    [date, title] = String.split(line, ",")
    {parse_date(date), title}
  end

  defp parse_date(date_string) do
    [year, month, day] = String.split(date_string, "/")
    {String.to_integer(year), String.to_integer(month), String.to_integer(day)}
  end

  defp transform_to_entry(raw) do
    {{year, month, day}, title} = raw
    {:ok, date} = Date.new(year, month, day)
    %{date: date, title: title}
  end
end

defimpl Collectable, for: TodoList do
  def into(original) do
    {original, &into_callback/2}
  end

  defp into_callback(todo_list, {:cont, entry}) do
    TodoList.add_entry(todo_list, entry)
  end
  defp into_callback(todo_list, :done), do: todo_list
  defp into_callback(todo_list, :halt), do: :ok
end
