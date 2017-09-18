#Genserver Module
defmodule BitcoinServer do
  use GenServer

  def start_link(k) do
    GenServer.start_link(BitcoinServer,k, name: :TM)
  end

  # Maintains a state with the k - input parameter and a Map to keep track of generated bitcoins.
  def init(k) do
      {:ok, {k, Map.new}}
  end

  # Send back a range of length for random strings the client is supposed to hash and check.
  def handle_call(:get_K, _from, state) do
    {k, _} = state
    returnObj = BitcoinLogic.loadBalancer()
    {:reply, {returnObj, k}, state}
  end

  # Sends back a random string of the requested size.
  def handle_call({:get_string, size}, _from, state) do
    salt = :crypto.strong_rand_bytes(size) |> Base.encode64 |> binary_part(0, size)
    {:reply, salt, state}
  end

  # Prints the bitcoins and their hash sent by the workers after filtering the duplicates.
  def handle_cast({:print_coin, inputStr, hashValue}, state) do
  {k, map} = state
      case Map.get(map, inputStr) do
      nil ->
        Bitcoinminer.printBitcoins(inputStr, hashValue)
        {:noreply, {k, Map.put(map, inputStr, hashValue)}}
      _ ->
      IO.puts "Found clash"
       {:noreply, state}
    end
  end

end

# The main module
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
    {ops_sys, extra } = :os.type
    ip = 
    case ops_sys do
      :unix -> 
            if extra == :linux do
              {:ok, [addr: ip]} = :inet.ifget('ens3', [:addr])
              to_string(:inet.ntoa(ip))
            else
              {:ok, [addr: ip]} = :inet.ifget('en0', [:addr])
              to_string(:inet.ntoa(ip))
            end
      :win32 -> {:ok, [ip, _]} = :inet.getiflist
               to_string(ip)
    end
  (ip)
  end

  # Starts a server node, initiates the GenServer and starts the mining on the server side.
  def start_link(k) do
    serverIP = IO.inspect findIP()
    local_node_name = String.to_atom("muginu@"<>serverIP)
    IO.inspect(Node.start(local_node_name))
    Node.set_cookie(String.to_atom("monster"))
    BitcoinServer.start_link(k)
    String.duplicate("0", k) |> BitcoinLogic.spawnXminingThreadsServer(serverIP) 
  end

  # Calls Genserver 
  def print_coin(inputStr, hashValue, ipAddr) do
    GenServer.cast({:TM, String.to_atom("muginu@"<>ipAddr)}, {:print_coin, inputStr, hashValue})
  end

  def get_K(ipAddr) do
    GenServer.call({:TM, String.to_atom("muginu@"<>ipAddr)}, :get_K, 10000)
  end

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
      clientMainMethod(String.duplicate("0", k), min_val, max_val, ipAddr)
    end
  end

  def getRandomStrClient(max_val, min_val) do
    len =Enum.random(min_val..max_val)
    salt = :crypto.strong_rand_bytes(len) |> Base.encode64 |> binary_part(0, len)
    "mmathkar" <> salt
  end

  def clientMainMethod(k, max_val, min_val, ipAddr) do
    getRandomStrClient(max_val,min_val) |>validateHashClient(k, ipAddr)
    clientMainMethod(k, max_val, min_val, ipAddr)
  end

  def validateHashClient(inputStr, comparator, ipAddr) do
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
     spawn(BitcoinLogic,:mainMethod, [k, 40, 1, serverIP])
     spawnXminingThreadsServer(k, serverIP)
  end

  def mainMethod(k, max_val, min_val, ipAddr) do
    Enum.random(min_val..max_val) |>validateHash(k, ipAddr)
    mainMethod(k, max_val, min_val, ipAddr)
  end

  # Load Balancer
  def loadBalancer do
    # Number of nodes connected (not counting self ) =   tuple_size(List.to_tuple(Node.list()))
    total_workers = tuple_size(List.to_tuple(Node.list())) + 1
    workUnit = 10
    loop(total_workers - 2 , workUnit)
  end

  def loop(i, workUnit) do
    {(workUnit*i + 40)+1, workUnit*(i+1) + 40}
  end

  def validateHash(size, comparator, serverIP) do
    inputStr = "mmathkar" <> GenServer.call({:TM, String.to_atom("muginu@"<>Bitcoinminer.findIP)}, {:get_string, size})
    hashVal=:crypto.hash(:sha256,inputStr) |> Base.encode16(case: :lower)
    bool = String.starts_with?(hashVal, comparator)
    if bool == true do
      GenServer.cast({:TM, String.to_atom("muginu@"<>Bitcoinminer.findIP)}, {:print_coin, inputStr, hashVal})
    end
  end

end