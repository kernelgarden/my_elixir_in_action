defmodule Calculator do
  def start do
    spawn(fn -> loop(0) end)
  end

  def add(server_pid, val) do
    send(server_pid, {:add, val})
  end

  def sub(server_pid, val) do
    send(server_pid, {:sub, val})
  end

  def mul(server_pid, val) do
    send(server_pid, {:mul, val})
  end

  def div(server_pid, val) do
    send(server_pid, {:div, val})
  end

  def get_value(server_pid) do
    send(server_pid, {:value, self()})

    receive do
      {:response, val} ->
        val
    after
      5000 ->
        {:error, :timeout}
    end
  end


  defp loop(state) do
    new_state =
      receive do
        message -> process_message(state, message)
      end

    loop(new_state)
  end

  defp process_message(cur_val, {:value, from_pid}) do
    send(from_pid, {:response, cur_val})
    cur_val
  end

  defp process_message(cur_val, {:add, val}) do
    cur_val + val
  end

  defp process_message(cur_val, {:sub, val}) do
    cur_val - val
  end

  defp process_message(cur_val, {:mul, val}) do
    cur_val * val
  end

  defp process_message(cur_val, {:div, val}) do
    case val == 0 do
      true ->
        IO.puts("cannot divide with 0")
        cur_val
      false ->
        cur_val / val
    end
  end

  defp process_message(cur_val, invalid_request) do
    IO.puts("invalid request: #{invalid_request}")
    cur_val
  end
end
