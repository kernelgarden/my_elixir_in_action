defmodule SimpleRegistry do
  use GenServer

  def start_link() do
    GenServer.start_link(
      __MODULE__,
      [],
      name: __MODULE__
    )
  end

  def registry(target_name) do
    GenServer.call(__MODULE__, {:registry, target_name})
  end

  def whereis(target_name) do
    GenServer.call(__MODULE__, {:whereis, target_name})
  end

  def child_spec(_) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []}
    }
  end

  def init(_) do
    Process.flag(:trap_exit, true)
    {:ok, %{}}
  end

  def handle_call({:registry, process_name}, _, process_map) do
    {res, new_map} = case Map.has_key?(process_map, process_name) do
      false ->
        module = name2module(process_name)
        {:ok, proc} = GenServer.start_link(module, [], name: module)
        new_map = Map.put(process_map, process_name, proc)
        {:ok, new_map}
      true ->
        {:error, process_map}
    end

    {:reply, res, new_map}
  end

  def handle_call({:whereis, process_name}, _, process_map) do
    {:reply, Map.get(process_map, process_name), process_map}
  end

  def handle_info({:EXIT, pid, reason}, process_map) do
    new_map = for {k, v} <- process_map, v != pid, into: %{}, do: {k, v}
    IO.puts("Dropped pid - #{inspect pid}, reason - #{reason}")
    {:noreply, new_map}
  end

  defp name2module(module_name) do
    :"Elixir.#{module_name}"
  end
end
