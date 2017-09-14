defmodule Bitcoinminer.Client do
#def connectServer(ipaddress) do
 #set iex --name
 #node.connect 
 #node="muginu@"<>ipaddress
 #Node.start()
 #Node.connect(node) 
#end
   def start_distributed(appname) do
    unless Node.alive?() do
      local_node_name = generate_name(appname)
      {:ok, _} = Node.start(local_node_name)
    end
    #cookie = Application.get_env(:APP_NAME, :cookie)
   Node.set_cookie(String.to_atom("monster"))
  # Node.set_cookie(cookie)
    #server=System.get_env("server")
    #Node.connect(server)
  end

  defp generate_name(appname) do
    machine = Application.get_env(appname, :machine, "localhost") #Returns the value for :machine in app’s environment
    hex = :erlang.monotonic_time() |>
      :erlang.phash2(256) |>
      Integer.to_string(16)
    String.to_atom("#{appname}-#{hex}@#{machine}")
  end
end