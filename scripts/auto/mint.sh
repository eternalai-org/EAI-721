#!/bin/bash

for i in {0..999}
do
  yarn ts:run scripts/nfts/cryptoai/5.mint.ts $i "address" "private_key"
  sleep 3
done
