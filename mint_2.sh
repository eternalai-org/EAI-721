#!/bin/bash

for i in {1000..1999}
do
  yarn ts:run scripts/nfts/cryptoai/5.mint.ts $i
done
