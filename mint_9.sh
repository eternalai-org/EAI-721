#!/bin/bash

for i in {8000..8999}
do
  yarn ts:run scripts/nfts/cryptoai/5.mint.ts $i
done
