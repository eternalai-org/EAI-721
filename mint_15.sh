#!/bin/bash


for i in {9999..9000}
do
  yarn ts:run scripts/nfts/cryptoai/5.mint.ts $i "0x40ABA054dfE7B5AA59094B437De3dF7AA9025D46" "7cf1b235b245c695ba90ce373b9c36fd96d23fd53d93a802baa33f7d8037d731"
done
