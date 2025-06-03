#!/bin/bash

yarn ts:run scripts/nfts/cryptoai/4.allowAdmin.ts "0xBa5626684C327f3bDB9b7A5970e162dEf6099E6B"

for i in {7000..7999}
do
  yarn ts:run scripts/nfts/cryptoai/5.mint.ts $i
done
