defmodule Bitcoinminer.Server2 do
    use GenServer

    #client side
     def start_link do
         IO.inspect(GenServer.start_link(Bitcoinminer.Server, :ok, []))
     end

    def print_coin(pid, inputStr, hashValue) do
        GenServer.cast(pid,{:print_coin, inputStr, hashValue})
    end

    def add_msg(pid, msg) do
        GenServer.cast(pid,{:add_msg,msg})
    end

    #server side/callback func
    def  init(msgs) do
        {:ok,msgs}
    end

    def handle_cast({:print_coin, inputStr, hashValue}) do
        {:noreply, fn -> Bitcoinminer.printBitcoins(inputStr, hashValue) end}
    end

    def handle_cast({:add_msg,msg},msgs) do
        {:noreply,[msg|msgs]}
    end
    
end
