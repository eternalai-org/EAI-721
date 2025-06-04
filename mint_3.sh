#!/bin/bash

for i in {2000..2999}
do
  yarn ts:run scripts/nfts/cryptoai/5.mint.ts $i "0x8ED58fc1331F92e663fB12A15B02af111d6a49d7" "18c91a2e1c898d390d545a6fa1ddab772755b16e3fb9ef4419e96853df359a28"
done
