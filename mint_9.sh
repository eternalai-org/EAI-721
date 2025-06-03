#!/bin/bash

yarn ts:run scripts/nfts/cryptoai/4.allowAdmin.ts "0x9D344558C2cB41e10E7289FC399beD85187bF26d"

for i in {8000..8999}
do
  yarn ts:run scripts/nfts/cryptoai/5.mint.ts $i
done
