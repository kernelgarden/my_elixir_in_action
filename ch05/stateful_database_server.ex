defmodule StatefulDatabaseServer do
  def start do
    # just simulate like a ODBC
    spawn(fn ->
      connection = :rand.uniform(1000)
      loop(connection)
    end)
  end

  def run_async(server_pid, query_def) do
    send(server_pid, {:run_query, self(), query_def})
  end

  def get_result() do
    receive do
      {:query_result, result} -> result
    after
      5000 -> {:error, :timeout}
    end
  end

  defp loop(state) do
    receive do
      {:run_query, from_pid, query_def} ->
        send(from_pid, {:query_result, run_query(state, query_def)})
    end

    loop(state)
  end

  defp run_query(connection, query_def) do
    Process.sleep(2000)
    "connection #{connection}: #{query_def} result"
  end
end
