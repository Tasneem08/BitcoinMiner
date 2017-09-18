#Genserver Module
defmodule BitcoinServer do
  use GenServer

  def start_link(k) do
    GenServer.start_link(BitcoinServer,k, name: :TM)
  end

  def init(k) do
      {:ok, k}
      #{:ok, Map.new}
  end

  def handle_call(:get_K, _from, k) do
    # CALL LOAD BALANCER HERE
    returnObj = BitcoinLogic.loadBalancer()
    {:reply, {returnObj, k}, k}
  end

  def handle_call(:get_blah, _from, k) do
    {:reply, k, k}
  end

  def handle_call(:get_string, _from, k) do
    len =40
    salt = :crypto.strong_rand_bytes(len) |> Base.encode64 |> binary_part(0, len)
    {:reply, salt, k}
  end

  def handle_cast({:print_coin, inputStr, hashValue}, k) do
    Bitcoinminer.printBitcoins(inputStr, hashValue)
    #     case Map.get(map, inputStr) do
    #   nil ->
    #     Bitcoinminer.printBitcoins(inputStr, hashValue)
    #     {:noreply, Map.put(map, inputStr, hashValue)}
    #   _ ->
       {:noreply, k}
    # end
  end

end

defmodule Bitcoinminer do
  # Entry point to the code. 
  def main(args) do
    try do
      k = List.first(args) |> String.to_integer()
      Bitcoinminer.start_link(k)
    rescue
      ArgumentError -> start_distributed(List.first(args))
    end
  end

  # Returns the IP address of the machine the code is being run on.
  def findIP do
    {ops_sys, _ } = :os.type
    ip = 
    case ops_sys do
      :unix -> {:ok, [addr: ip]} = :inet.ifget('en0', [:addr])
               to_string(:inet.ntoa(ip))
      :win32 -> {:ok, [ip, _]} = :inet.getiflist
               to_string(ip)
    end
  (ip)
  end

  def start_link(k) do
   IO.puts("In Start Link")
    serverIP = findIP()
    local_node_name = String.to_atom("muginu@"<>serverIP)
    IO.inspect(Node.start(local_node_name))
    Node.set_cookie(String.to_atom("monster"))
    BitcoinServer.start_link(k)
    String.duplicate("0", k) |> BitcoinLogic.spawnXminingThreadsServer(serverIP) 
  end

  def print_coin(inputStr, hashValue, ipAddr) do
    #[serverIP] = Registry.keys(Registry.ServerInfo, self())
    GenServer.cast({:TM, String.to_atom("muginu@"<>ipAddr)}, {:print_coin, inputStr, hashValue})
  end

  def get_K(ipAddr) do
    #[serverIP] = Registry.keys(Registry.ServerInfo, self())
    GenServer.call({:TM, String.to_atom("muginu@"<>ipAddr)}, :get_K, 10000)
  end

    #server side/callback func
  ### Client

  # Prints found Bitcoins and their hash to the console.
  def printBitcoins(inputStr, hashVal) do
    IO.puts "#{inputStr}\t#{hashVal}"
  end

  def start_distributed(ipAddr) do
    local_node_name = String.to_atom("mmathkar"<>(:erlang.monotonic_time() |> :erlang.phash2(256) |> Integer.to_string(16))<>"@"<>findIP())
    IO.inspect(Node.start(local_node_name))
    Node.set_cookie(String.to_atom("monster"))
    result = IO.inspect(Node.connect(String.to_atom("muginu@"<>ipAddr)))
    if result == true do
      {{max_val, min_val}, k} = IO.inspect(get_K(ipAddr))
      #spawnXminingThreadsClient(String.duplicate("0", k), min_val, max_val)
      clientMainMethod(String.duplicate("0", k), min_val, max_val, ipAddr)
    end
  end

  def clientMainMethod(k, max_val, min_val, ipAddr) do
    getRandomStrClient(max_val, min_val)|>validateHashClient(k, ipAddr)
    clientMainMethod(k, max_val, min_val, ipAddr)
  end

  def getRandomStrClient(max_val, min_val) do
    #IO.puts("Found the range as #{max_val} - #{min_val}")
    len =Enum.random(min_val..max_val)
    salt = :crypto.strong_rand_bytes(len) |> Base.encode64 |> binary_part(0, len)
    "mmathkar" <> salt
  end

  def validateHashClient(inputStr,comparator, ipAddr) do
    hashVal=:crypto.hash(:sha256,inputStr) |> Base.encode16(case: :lower)
    bool = String.starts_with?(hashVal, comparator)
    if bool == true do
      print_coin(inputStr,hashVal, ipAddr)
    end
  end
end

defmodule BitcoinLogic do

  # def spawnXminingThreadsServer(k, count, intx, serverIP) when count < intx do
  #   IO.puts(count)
  #    spawn(BitcoinLogic,:validateHash, [k, serverIP])
  #    spawnXminingThreadsServer(k, count+1, intx, serverIP)
  # end

  def spawnXminingThreadsServer(k, serverIP) do
     spawn(BitcoinLogic,:validateHash, [k, serverIP])
     spawnXminingThreadsServer(k, serverIP)
  end


  # Load Balancer
  def loadBalancer do
    # Number of nodes connected (not counting self ) =   tuple_size(List.to_tuple(Node.list()))
    max_size = 100
    total_workers = tuple_size(List.to_tuple(Node.list())) + 1
    #workUnit = round(max_size/total_workers)
    workUnit = 10
    loop(List.to_tuple(Node.list()), total_workers - 2 , 0, workUnit, %{})
  end

  def loop(tuple, i, worker_max, workUnit, map) do
    {(workUnit*i)+1, workUnit*(i+1)}
  end

  def validateHash(comparator, serverIP) do
    inputStr = "mmathkar" <> GenServer.call({:TM, String.to_atom("muginu@"<>Bitcoinminer.findIP())}, :get_string)
    hashVal=:crypto.hash(:sha256,inputStr) |> Base.encode16(case: :lower)
    bool = String.starts_with?(hashVal, comparator)
    if bool == true do
      GenServer.cast({:TM, String.to_atom("muginu@"<>Bitcoinminer.findIP)}, {:print_coin, inputStr, hashVal})
    end
    validateHash(comparator, serverIP)
  end

end