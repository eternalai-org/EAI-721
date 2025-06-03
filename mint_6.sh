#!/bin/bash

for i in {5000..5999}
do
  yarn ts:run scripts/nfts/cryptoai/5.mint.ts $i
done
