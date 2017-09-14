defmodule Bitcoinminer.Server do
    use GenServer

    #client side
     def start_link do
         GenServer.start_link(Bitcoinminer.Server, [])
     end

    def get_msgs(pid) do
        GenServer.call(pid,:get_msgs)
    end

    def add_msg(pid, msg) do
        GenServer.cast(pid,{:add_msg,msg})
    end

    #server side/callback func
    def  init(msgs) do
        {:ok,msgs}
    end

    def handle_call(:get_msgs,_from,msgs) do
        {:reply,msgs,msgs}
    end

    def handle_cast({:add_msg,msg},msgs) do
        {:noreply,[msg|msgs]}
    end

end
