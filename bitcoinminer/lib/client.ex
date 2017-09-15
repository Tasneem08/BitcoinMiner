defmodule Bitcoinminer.Client2 do
#def connectServer(ipaddress) do
 #set iex --name
 #node.connect 
 #node="muginu@"<>ipaddress
 #Node.start()
 #Node.connect(node) 
#end

   def start_distributed(k) do
    unless Node.alive?() do
      local_node_name = generate_name("mmathkar")
      {:ok, _} = Node.start(local_node_name)
    end
    #cookie = Application.get_env(:APP_NAME, :cookie)
   Node.set_cookie(String.to_atom("monster"))
  # Node.set_cookie(cookie)
    #server=System.get_env("server")
    result = Node.connect(String.to_atom("muginu@10.192.55.89"))
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
    IO.puts "#{inputStr}    #{hashVal}"
    
  end
  end

end