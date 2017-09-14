defmodule Bitcoinminer do
  use Application

  def start(_type,_args) do
  #unless Process.whereis(:store) do
  #  {:ok, pid} = Bitcoinminer.MapOps.start_link()
  #  Process.register(pid, :store)
  #end
    Bitcoinminer.Supervisor.start_link
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
