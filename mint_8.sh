#!/bin/bash

for i in {7000..7999}
do
  yarn ts:run scripts/nfts/cryptoai/5.mint.ts $i "0xBa5626684C327f3bDB9b7A5970e162dEf6099E6B" "d42551cbe0f1fc2121a3e0c94ed984b65bd5d4f15c013049c11b3384c57eb0b7"
  sleep 3
done
