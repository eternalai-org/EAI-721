#!/bin/bash

for i in {0..10000}
do
  yarn ts:run scripts/nfts/cryptoai/5.mint.ts $i
done
