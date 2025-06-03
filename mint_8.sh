#!/bin/bash

for i in {7000..7999}
do
  yarn ts:run scripts/nfts/cryptoai/5.mint.ts $i
done
