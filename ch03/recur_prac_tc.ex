defmodule RecurPracTc do
  @moduledoc """
  This is tail recursive version
  """


  # list_len/1 return length
  # range/2 return list of range
  # positive/1 return list of positive elements

  def list_len(li) do
    do_list_len(li, 0)
  end
  defp do_list_len([], cur_len), do: cur_len
  defp do_list_len([head | tail], cur_len) do
    do_list_len(tail, cur_len + 1)
  end

  def range(from, to) do
    do_range(from, to, [])
  end
  defp do_range(from, to, acc) when from > to, do: acc
  defp do_range(from, to, acc) do
    do_range(from, to - 1, [to | acc])
  end

  def positive(li) do
    do_positive(Enum.reverse(li), [])
  end
  defp do_positive([], acc), do: acc
  defp do_positive([head | tail], acc) do
    do_positive(tail, [abs(head) | acc])
  end
end
