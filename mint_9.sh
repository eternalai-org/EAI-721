#!/bin/bash

for i in {8000..8999}
do
  yarn ts:run scripts/nfts/cryptoai/5.mint.ts $i "0x9D344558C2cB41e10E7289FC399beD85187bF26d" "032e833cd6c2dac84b35163c8aa5e44a8d7206dbf7bfdea2a39c837dc2ac5410"
  sleep 3
done
