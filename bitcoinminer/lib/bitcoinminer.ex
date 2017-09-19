#Genserver Module
defmodule BitcoinServer do
  use GenServer

  def start_link(k) do
    GenServer.start_link(BitcoinServer, k, name: :TM)
  end

  # Maintains a state with the k - input parameter and a Map to keep track of generated bitcoins.
  def init(k) do
      {:ok, {k, Map.new}}
  end

  # Send back a range of length for random strings the client is supposed to hash and check.
  def handle_call(:get_work, _from, state) do
    {k, _} = state
    i = tuple_size(List.to_tuple(Node.list())) - 1
    workUnit = 10
    returnObj = {(workUnit*i + 40)+1, workUnit*(i+1) + 40}
    {:reply, {returnObj, k}, state}
  end

  # Prints the bitcoins and their hash sent by the workers after filtering the duplicates.
  def handle_cast({:print_coin, inputStr, hashValue}, state) do
  {k, map} = state
      case Map.get(map, inputStr) do
      nil ->
        Bitcoinminer.printBitcoins(inputStr, hashValue)
        {:noreply, {k, Map.put(map, inputStr, hashValue)}}
      _ ->
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
     :timer.sleep(:infinity)
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
    serverIP = findIP() 
    server_name = String.to_atom("muginu@"<>serverIP)
    Node.start(server_name)
    cookie_name = String.to_atom("monster")
    Node.set_cookie(cookie_name)
    BitcoinServer.start_link(k)
    String.duplicate("0", k) |> BitcoinLogic.spawnXminingThreadsServer(server_name)
    :timer.sleep(:infinity)
  end

  # Calls Genserver to print found bitcoins
  def print_coin(inputStr, hashValue, ipAddr) do
    GenServer.cast({:TM, String.to_atom("muginu@"<>ipAddr)}, {:print_coin, inputStr, hashValue})
  end

  # Calls Genserver to ask for work load
  def get_work(ipAddr) do
    GenServer.call({:TM, String.to_atom("muginu@"<>ipAddr)}, :get_work, 10000)
  end

  # Prints found Bitcoins and their hash to the console.
  def printBitcoins(inputStr, hashVal) do
    IO.puts "#{inputStr}\t#{hashVal}"
  end

 # Sets up the worker/ Client
  def start_distributed(ipAddr) do
    local_node_name = String.to_atom("mmathkar"<>(:erlang.monotonic_time() |> :erlang.phash2(256) |> Integer.to_string(16))<>"@"<>findIP())
    Node.start(local_node_name)
    Node.set_cookie(String.to_atom("monster"))
    if Node.connect(String.to_atom("muginu@"<>ipAddr)) == true do
      {{max_val, min_val}, k} = get_work(ipAddr)
      clientMainMethod(String.duplicate("0", k), min_val, max_val, ipAddr)
    end
  end

  # Generates a random string within the range provided
  def getRandomStrClient(max_val, min_val) do
    len =Enum.random(min_val..max_val)
    salt = :crypto.strong_rand_bytes(len) |> Base.encode64 |> binary_part(0, len)
    "mmathkar" <> salt
  end

  # the recurrsive method that handles mining at client
  def clientMainMethod(k, max_val, min_val, ipAddr) do
    getRandomStrClient(max_val,min_val) |> validateHashClient(k, ipAddr)
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

  def spawnXminingThreadsServer(k, server_name) do
  for _ <- 1..512 do
        spawn(fn -> mainMethod(k, 40, 1, server_name) end)
        end
  end

  def mainMethod(k, max_val, min_val, server_name) do
    Enum.random(min_val..max_val) |>validateHash(k, server_name)
    mainMethod(k, max_val, min_val, server_name)
  end

  def validateHash(size, comparator, server_name) do
    inputStr = "mmathkar" <> (:crypto.strong_rand_bytes(size) |> Base.encode64 |> binary_part(0, size))
    hashVal=:crypto.hash(:sha256,inputStr) |> Base.encode16(case: :lower)
    if String.starts_with?(hashVal, comparator) == true do
      GenServer.cast({:TM, server_name}, {:print_coin, inputStr, hashVal})
    end
  end

end