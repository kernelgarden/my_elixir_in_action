defmodule EnumStreamsPrac do
  """
  lines_lengths!/1 that takes a file path and returns a list of numbers, with each number
representing the length of the corresponding line from the file.
longest_line_length!/1 that returns the length of the longest line in a file.
longest_line!/1 that returns the contents of the longest line in a file.
words_per_line!/1 that returns a list of numbers, with each number representing the
word count in a file. Hint: to get the word count of a line, use
length(String.split(line))
  """
  def get_test_path(), do: Path.expand('dummy.txt') |> Path.absname()

  def line_lengths!(path) do
    File.stream!(path)
    |> Stream.map(&String.replace(&1, "\n", ""))
    |> Enum.map(&String.length(&1))
  end

  def longest_line_length!(path) do
    File.stream!(path)
    |> Stream.map(&String.replace(&1, "\n", ""))
    |> Enum.reduce(0, fn line, acc -> is_larger_than_num(line, acc) end)
  end

  defp is_larger_than_num(line, num) do
    target_length = String.length(line)
    case target_length > num do
      true -> target_length
      false -> num
    end
  end

  def longest_line!(path) do
    File.stream!(path)
    |> Stream.map(&String.replace(&1, "\n", ""))
    |> Enum.reduce("", fn line, acc -> is_larger_than_string(line, acc) end)
  end

  defp is_larger_than_string(line, compare_string) do
    line_length = String.length(line)
    compare_length = String.length(compare_string)

    case line_length > compare_length do
      true -> line
      false -> compare_string
    end
  end

  def words_per_line!(path) do
    File.stream!(path)
    |> Stream.map(&String.replace(&1, "\n", ""))
    |> Enum.map(fn line -> get_words_count(line) end)
  end

  defp get_words_count(line) do
    String.split(line, " ")
    |> length()
  end
end
