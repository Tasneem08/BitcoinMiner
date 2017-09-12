defmodule Bitcoinminer do
  
  
  def getRandomStr do
  len =10
  salt = :crypto.strong_rand_bytes(len) |> Base.encode64 |> binary_part(0, len)
  IO.puts "#{salt}"
  "mmathkar" <> salt
  end

  def calculateSha(inputStr,k) do
  comparator = getKZeroes(k)
  hashVal=:crypto.hash(:sha256,inputStr) |> Base.encode16(case: :lower)
  String.starts_with?(hashVal, comparator)
  end

  def getKZeroes(k) do
   "0"
  end
  def mainMethod(k) do
  getRandomStr()|>calculateSha(k)
  end
end

