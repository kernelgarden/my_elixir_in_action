defmodule Todo.List.CsvImporter do
  def get_test_path(), do: Path.expand('dummy.csv') |> Path.absname()

  def import(path) do
    read_csv(path)
  end

  defp read_csv(path) do
    entities = File.stream!(path)
    |> Stream.map(&String.replace(&1, "\n", ""))
    |> Enum.map(fn line -> transform_to_entry(parse_line(line)) end)

    Todo.List.new(entities)
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
