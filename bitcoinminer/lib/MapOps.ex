defmodule Bitcoinminer.MapOps do

  def start_link(initial_map \\ %{}) do
    Task.start_link(fn -> loop(initial_map) end)
  end

  defp loop(map) do
    receive do
      {:get_key, key, caller} ->
        send caller, Map.get(map, key)
        loop(map)
      {:put, key, value} ->
        loop(Map.put(map, key, value))
    end
  end
  
end