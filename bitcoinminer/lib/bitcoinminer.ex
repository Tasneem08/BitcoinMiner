defmodule Bitcoinminer do
  use GenServer

  # Entry point to the code. 
  def main(args) do
   try do
      k = List.first(args) |> String.to_integer()
      start_link()
      Registry.start_link(:unique, Registry.BitcoinSpecs)
      Registry.register(Registry.BitcoinSpecs, "kzeroes", String.to_atom(Integer.to_string(k)))
      IO.inspect(Registry.lookup(Registry.BitcoinSpecs, "kzeroes"))
      k |> getKZeroes() |> mainMethod()
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
  
  # Load Balancer
    # called from get_k. matlab new worker joined and you gotta re-distribute the load
    # Try to equally divide the string size.
    # Keep a registry for load assigned ?
    # Try to maintain a map?
    # Store a range of size assigned to each worker.
  def loadBalancer do
    # Number of nodes connected (not counting self ) =   tuple_size(List.to_tuple(Node.list()))
    max_size = 100
    total_workers = tuple_size(List.to_tuple(Node.list())) + 1
    
    # for(i=1;i<total_workers; i++)
    # {
    #     worker_min = worker_max + 1
    #     worker_max = (max_size/total_workers) * i
    #     send to worker pid -> {worker_min, worker_max}
    # }
    workUnit = (max_size/total_workers)
    loop(List.to_tuple(Node.list()), total_workers - 2 , 0, workUnit)
    end


    def loop(tuple, i, worker_max, workUnit) do
    if i>= 0 do
        worker_min = worker_max + 1
        worker_max = worker_max + workUnit

        IO.puts("For #{elem(tuple,i)}  Min Size = #{worker_min}     Max Size = #{worker_max}")
        loop(tuple, i-1, worker_max, workUnit)
    end
    end

  # Returns a string with k zeroes
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

  # Prints found Bitcoins and their hash to the console.
  def printBitcoins(inputStr, hashVal) do
    map=%{inputStr=>hashVal}
    isPresent = Map.has_key?(map,inputStr)
    if isPresent == true do
    IO.puts "#{inputStr}    #{hashVal}"
    end
    end


### Server 

     def start_link() do
       IO.puts "In START LINK"
        unless Node.alive?() do
        local_node_name = String.to_atom("muginu@"<>findIP())
        {:ok, _} = Node.start(local_node_name)
        end
        Node.set_cookie(String.to_atom("monster"))
        GenServer.start_link(Bitcoinminer,[], name: :TM)
     end

    def print_coin(inputStr, hashValue) do
        [serverIP] = Registry.keys(Registry.ServerInfo, self())
        IO.inspect(GenServer.cast({:TM, String.to_atom("muginu@"<>serverIP)}, {:print_coin, inputStr, hashValue}))
    end

    def get_K do
        
        [serverIP] = Registry.keys(Registry.ServerInfo, self())
        IO.inspect(GenServer.call({:TM, String.to_atom("muginu@"<>serverIP)}, :get_K))
        
    end

    def add_msg(msg) do
        GenServer.cast(:chat_room,{:add_msg,msg})
    end

    #server side/callback func
    def init(messages) do
      {:ok, messages}
    end

    def handle_call(:get_K, _from, messages) do
      # CALL LOAD BALANCER HERE
      loadBalancer()
      [{_, k}] = Registry.lookup(Registry.BitcoinSpecs, "kzeroes")
      {:reply, String.to_integer(Atom.to_string(k)), messages}
  end

    def handle_cast({:print_coin, inputStr, hashValue}, messages) do
        printBitcoins(inputStr, hashValue)
        {:noreply,[inputStr | messages]}
    end

    def handle_cast({:add_msg,msg},msgs) do
        {:noreply,[msg|msgs]}
    end


### Client

   def start_distributed(ipAddr) do

   # store the IP
   Registry.start_link(:unique, Registry.ServerInfo)
   Registry.register(Registry.ServerInfo, ipAddr, :serverIP)

    unless Node.alive?() do
      local_node_name = String.to_atom("mmathkar"<>(:erlang.monotonic_time() |> :erlang.phash2(256) |> Integer.to_string(16)))
      {:ok, _} = Node.start(local_node_name)
    end
   
    Node.set_cookie(String.to_atom("monster"))
    result = Node.connect(String.to_atom("muginu@"<>ipAddr))
    if result == true do
      k = get_K()
      IO.puts "RECEIVED K AS #{k}"
      clientMainMethod(String.duplicate("0", k))
    end
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


  # defp generate_name(appname) do
  #   machine = Application.get_env(appname, :machine, "localhost") #Returns the value for :machine in app’s environment
  #   hex = :erlang.monotonic_time() |>
  #     :erlang.phash2(256) |>
  #     Integer.to_string(16)
  #   String.to_atom("#{appname}-#{hex}@#{machine}")
  # end