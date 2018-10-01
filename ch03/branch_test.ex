defmodule BranchTest do

  def if_max(a, b) do
    if a >= b, do: a, else: b
  end

  def unless_max(a, b) do
    unless a >= b, do: b, else: a
  end

  # like a if else if else...
  def cond_max(a, b) do
    cond do
      a >= b -> a

      true -> b
    end
  end

  def case_max(a, b) do
    case a >= b do
      true -> a
      false -> b
    end
  end

end
