#!/bin/bash

for i in {9000..9999}
do
  yarn ts:run scripts/nfts/cryptoai/5.mint.ts $i
done
