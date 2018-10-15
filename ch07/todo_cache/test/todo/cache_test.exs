defmodule Todo.Cache.Test do
  use ExUnit.Case

  test "generate and query cache" do
    Todo.Cache.start()
    servers =
      1..100
      |> Enum.map(&(Todo.Cache.server_process(&1)))

    assert length(servers) == 100

    queries =
      1..100
      |> Enum.map(&(Todo.Cache.server_process(&1)))

    assert servers == queries
  end
end
