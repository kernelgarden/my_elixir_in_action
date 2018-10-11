defmodule ServerProcess do
  def start(callback_module) do
    spawn(fn ->
      initial_state = callback_module.init()
      loop(callback_module, initial_state)
    end)
  end

  def call(server_pid, request) do
    send(server_pid, {:call, request, self()})

    receive do
      {:response, response} -> response
    end
  end

  def cast(server_pid, request) do
    send(server_pid, {:cast, request})
  end

  defp loop(callback_module, current_state) do
    receive do
      {:call, request, caller_pid} ->
        {response, new_state} =
          callback_module.handle_call(
            request,
            current_state
          )

        send(caller_pid, {:response, response})

        loop(callback_module, new_state)

      {:cast, request} ->
        new_state =
          callback_module.handle_cast(
            request,
            current_state
          )

        loop(callback_module, new_state)
    end
  end
end

defmodule KeyValueStore do
  def init() do
    %{}
  end

  def handle_call({:put, key, value}, cur_state) do
    {:ok, Map.put(cur_state, key, value)}
  end

  def handle_call({:get, key}, cur_state) do
    {Map.get(cur_state, key), cur_state}
  end

  def handle_cast({:put, key, value}, cur_state) do
    Map.put(cur_state, key, value)
  end
end
