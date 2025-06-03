#!/bin/bash

for i in {3000..3999}
do
  yarn ts:run scripts/nfts/cryptoai/5.mint.ts $i
done
