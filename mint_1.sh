#!/bin/bash

yarn ts:run scripts/nfts/cryptoai/4.allowAdmin.ts "0x828Ee203A105530d8B755c22eB72Eb58CA8FF8e1"

for i in {0..999}
do
  yarn ts:run scripts/nfts/cryptoai/5.mint.ts $i
done
