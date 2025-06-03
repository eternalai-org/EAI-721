#!/bin/bash

for i in {2000..2999}
do
  yarn ts:run scripts/nfts/cryptoai/5.mint.ts $i "0x8ED58fc1331F92e663fB12A15B02af111d6a49d7"
done
