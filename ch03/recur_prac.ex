defmodule RecurPrac do
  @moduledoc """
  This is non tail recursive version
  """


  # list_len/1 return length
  # range/2 return list of range
  # positive/1 return list of positive elements

  def list_len([]), do: 0
  def list_len([head | tail]) do
    1 + list_len(tail)
  end

  def range(from, to) when from > to, do: []
  def range(from, to) do
    [from | range(from + 1, to)]
  end

  def positive([]), do: []
  def positive([head | tail]) do
    [abs(head) | positive(tail)]
  end
end
