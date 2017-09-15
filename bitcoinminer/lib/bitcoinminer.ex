defmodule Bitcoinminer do
  use Application

  def start(_type,_args) do
  #unless Process.whereis(:store) do
  #  {:ok, pid} = Bitcoinminer.MapOps.start_link()
  #  Process.register(pid, :store)
  #end
    Bitcoinminer.Server.start_link
  end

  def main(args) do
    List.first(args) |> String.to_integer() |> getKZeroes() |> mainMethod()
  end

  defp getKZeroes(k) do
   String.duplicate("0", k)
  end

  defp mainMethod(k) do
  getRandomStr()|>validateHash(k)
  mainMethod(k)
  end

  defp getRandomStr do
  len =40
  salt = :crypto.strong_rand_bytes(len) |> Base.encode64 |> binary_part(0, len)
  "mmathkar" <> salt
  end

  defp validateHash(inputStr,comparator) do
  hashVal=:crypto.hash(:sha256,inputStr) |> Base.encode16(case: :lower)
  bool = String.starts_with?(hashVal, comparator)
  if bool == true do
    printBitcoins(inputStr, hashVal)
  end
  end

  def printBitcoins(inputStr, hashVal) do
    map=%{inputStr=>hashVal}
    isPresent = Map.has_key?(map,inputStr)
    if isPresent == true do
    IO.puts "#{inputStr}    #{hashVal}"
   # isPresent = send :store, {:get_key, inputStr, self()}
   # IO.inspect "#{isPresent}"
    #send :store, {:put, inputStr, hashVal}
    end
    end

end


### Server 

defmodule Bitcoinminer.Server do
    use GenServer

    #client side
     def start_link do
         IO.inspect(GenServer.start_link(Bitcoinminer.Server, :ok,name: :TM))
     end

    def print_coin(pid, inputStr, hashValue) do
        IO.puts "~~~~~~~~Reached here !!! Client tried to call GenServer !!!!!!!"
        GenServer.cast({:TM, pid},{:print_coin, inputStr, hashValue})
    end

    def add_msg(pid, msg) do
        GenServer.cast(pid,{:add_msg,msg})
    end

    #server side/callback func
    def  init(msgs) do
        {:ok,msgs}
    end

    def handle_cast({:print_coin, inputStr, hashValue}) do
        IO.puts "~~~~~~~~Reached here !!! Client tried to print something !!!!!!!"
        Bitcoinminer.printBitcoins(inputStr, hashValue)
        {:noreply}
    end

    def handle_cast({:add_msg,msg},msgs) do
        {:noreply,[msg|msgs]}
    end
    
end


### Client

defmodule Bitcoinminer.Client do

   def start_distributed(k) do
    unless Node.alive?() do
      local_node_name = generate_name("mmathkar")
      {:ok, _} = Node.start(local_node_name)
    end
    #cookie = Application.get_env(:APP_NAME, :cookie)
   Node.set_cookie(String.to_atom("monster"))
  # Node.set_cookie(cookie)
    #server=System.get_env("server")
    result = Node.connect(String.to_atom("muginu@10.136.95.124"))
    if result == true do
      mainMethod(String.duplicate("0", k))
    end
  end

  defp generate_name(appname) do
    machine = Application.get_env(appname, :machine, "localhost") #Returns the value for :machine in app’s environment
    hex = :erlang.monotonic_time() |>
      :erlang.phash2(256) |>
      Integer.to_string(16)
    String.to_atom("#{appname}-#{hex}@#{machine}")
  end

  def main(args) do
    List.first(args) |> String.to_integer() |> getKZeroes() |> mainMethod()
  end

  defp getKZeroes(k) do
   String.duplicate("0", k)
  end

  defp mainMethod(k) do
  getRandomStr()|>validateHash(k)
  mainMethod(k)
  end

  defp getRandomStr do
  len =5
  salt = :crypto.strong_rand_bytes(len) |> Base.encode64 |> binary_part(0, len)
  "mmathkar" <> salt
  end

  defp validateHash(inputStr,comparator) do
  hashVal=:crypto.hash(:sha256,inputStr) |> Base.encode16(case: :lower)
  bool = String.starts_with?(hashVal, comparator)
  if bool == true do
    #IO.puts "#{inputStr}    #{hashVal}"
    Bitcoinminer.Server.print_coin(String.to_atom("#PID<0.83.0>"),inputStr,hashVal)
  end
  end

end
