#!/bin/bash

for i in {6000..6999}
do
  yarn ts:run scripts/nfts/cryptoai/5.mint.ts $i
done
