defmodule Bitcoinminer do
  use Application, GenServer

  def start(_type,_args) do
  #unless Process.whereis(:store) do
  #  {:ok, pid} = Bitcoinminer.MapOps.start_link()
  #  Process.register(pid, :store)
  #end
     start_server()
  end

  def main(args) do
    #k1=List.first(args) |> String.to_integer() |> getKZeroes() |> mainMethod()
    k1=List.first(args) |> String.to_integer() 
    #set_K(k1)
   # k1|>start_server()
    getKZeroes(k1) |> mainMethod()
  end
  
  # def set_K(k) do
  # k=k1
  # end

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


### Server 

    #client side
     def start_server() do
        # k=set_K
         GenServer.start_link(Bitcoinminer,:ok, name: :TM)#k is the state
     end

    def print_coin(inputStr, hashValue) do
        IO.inspect(GenServer.cast({:TM, :'muginu@10.136.196.248'}, {:print_coin, inputStr, hashValue}))
        
    end

    def get_K do
        IO.inspect(GenServer.call(:TM, :get_K))
        
    end

    def add_msg(msg) do
        GenServer.cast(:chat_room,{:add_msg,msg})
    end

    #server side/callback func
    def init(messages) do
    IO.inspect(messages)
    IO.puts("init")
      {:ok, messages}
    end

    def handle_call({:get_K}, _from, k) do
    {:reply,k, k}
  end

    def handle_cast({:print_coin, inputStr, hashValue}, messages) do
        printBitcoins(inputStr, hashValue)
        {:noreply,[inputStr | messages]}
    end

    def handle_cast({:add_msg,msg},msgs) do
        {:noreply,[msg|msgs]}
    end


### Client

   def start_distributed(k) do
    unless Node.alive?() do
      local_node_name = generate_name("mmathkar")
      {:ok, _} = Node.start(local_node_name)
    end
    #cookie = Application.get_env(:APP_NAME, :cookie)
   Node.set_cookie(String.to_atom("monster"))
  # Node.set_cookie(cookie)
    #server=System.get_env("server")
    result = Node.connect(String.to_atom("muginu@10.136.196.248"))
    if result == true do
     # k = get_K()
      clientMainMethod(String.duplicate("0", k))
    end
  end

  defp generate_name(appname) do
    machine = Application.get_env(appname, :machine, "localhost") #Returns the value for :machine in app’s environment
    hex = :erlang.monotonic_time() |>
      :erlang.phash2(256) |>
      Integer.to_string(16)
    String.to_atom("#{appname}-#{hex}@#{machine}")
  end

  defp clientMainMethod(k) do
  getRandomStrClient()|>validateHashClient(k)
  clientMainMethod(k)
  end

  defp getRandomStrClient do
  len =5
  salt = :crypto.strong_rand_bytes(len) |> Base.encode64 |> binary_part(0, len)
  "mmathkar" <> salt
  end

  defp validateHashClient(inputStr,comparator) do
  hashVal=:crypto.hash(:sha256,inputStr) |> Base.encode16(case: :lower)
  bool = String.starts_with?(hashVal, comparator)
  if bool == true do
    print_coin(inputStr,hashVal)
  end
  end

  end
