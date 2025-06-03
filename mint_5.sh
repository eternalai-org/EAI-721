#!/bin/bash

for i in {4000..4999}
do
  yarn ts:run scripts/nfts/cryptoai/5.mint.ts $i
done
