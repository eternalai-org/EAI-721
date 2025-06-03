#!/bin/bash

for i in {2000..2999}
do
  yarn ts:run scripts/nfts/cryptoai/5.mint.ts $i
done
