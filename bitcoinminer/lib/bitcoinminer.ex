defmodule Bitcoinminer do
  
  
  def getRandomStr do
  len =10
  salt = :crypto.strong_rand_bytes(len) |> Base.encode64 |> binary_part(0, len)
  "mmathkar" <> salt
  end

<<<<<<< HEAD
  def calculateSha(inputStr,k) do
  hashVal=:crypto.hash(:sha256,inputStr) |> Base.encode16(case: :lower)
  String.starts_with?(hashVal, k)
  end

  
  def mainMethod(k) do
  comparator= String.duplicate("0",k)
  getRandomStr()|>calculateSha(comparator)
=======
  def validateHash(inputStr,k) do
  comparator = getKZeroes(k)
  hashVal=:crypto.hash(:sha256,inputStr) |> Base.encode16(case: :lower)
  bool = String.starts_with?(hashVal, comparator)
  if bool == true do
    IO.puts "#{inputStr}    #{hashVal}"
  end
  end

  def getKZeroes(k) do
   String.duplicate("0", k)
  end
  
  def mainMethod(k) do
  getRandomStr()|>validateHash(k)
  mainMethod(k)
>>>>>>> 7980950dfb2148dafc7df947683892e126293a6a
  end

end
