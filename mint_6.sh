#!/bin/bash

yarn ts:run scripts/nfts/cryptoai/4.allowAdmin.ts "0x96bd62a6b40A051971526b4Ec3b5bDa31e6D4994"

for i in {5000..5999}
do
  yarn ts:run scripts/nfts/cryptoai/5.mint.ts $i
done
