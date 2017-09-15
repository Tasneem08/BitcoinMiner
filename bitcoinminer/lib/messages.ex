defmodule Bitcoinminer.Messages do

  def start_link() do
    Task.start_link(fn -> loop() end)
  end

  defp loop do
    receive do
      {:get_pid, caller} ->
        send caller, Node.self()
        loop()
      {:print, key, value} ->
        fn -> Bitcoinminer.printBitcoins(key, value) end
        loop()
    end
  end
  
end
