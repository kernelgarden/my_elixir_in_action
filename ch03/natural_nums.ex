defmodule NaturalNums do

  def print(0), do: IO.puts(0)

  def print(1), do: IO.puts(1)
  def print(n) when is_integer(n) and n > 0 do
    print(n - 1)
    IO.puts(n)
  end

  def print(-1), do: IO.puts(-1)
  def print(n) when is_integer(n) and n < 0 do
    print(n + 1)
    IO.puts(n)
  end

  def print(_), do: {:error, :non_integer}
end
