defmodule SumListTc do

  defp sum([], acc), do: acc
  defp sum([head | tail], acc) do
    sum(tail, acc + head)
  end
  def sum([]), do: 0
  def sum(li) when is_list(li) do
    sum(li, 0)
  end
end
