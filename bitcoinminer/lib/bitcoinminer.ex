defmodule Bitcoinminer do

  def getRandomStr do
  len =10
  salt = :crypto.strong_rand_bytes(len) |> Base.encode64 |> binary_part(0, len)
  "mmathkar" <> salt
  end

  def validateHash(inputStr,k) do
  comparator = getKZeroes(k)
  hashVal=:crypto.hash(:sha256,inputStr) |> Base.encode16(case: :lower)
  bool = String.starts_with?(hashVal, comparator)
  if bool == true do
    
    #mapBool=map.has_key?(inputStr)
    #if mapBool == false do
    isPresent = Map.has_key?(map,inputStr)
    if isPresent == false do
    map=%{inputStr=>hashVal}
    IO.puts "#{inputStr}    #{hashVal}"
    end
    
    
  end
  end

  def getKZeroes(k) do
   String.duplicate("0", k)
  end
  
  def mainMethod(k) do
  getRandomStr()|>validateHash(k)
  mainMethod(k)
  end

end
