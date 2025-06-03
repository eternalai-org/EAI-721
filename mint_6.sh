#!/bin/bash


for i in {5000..5999}
do
  yarn ts:run scripts/nfts/cryptoai/5.mint.ts $i "0x96bd62a6b40A051971526b4Ec3b5bDa31e6D4994" "ed96e3fb3d38fb3df78b4bdcafe68d78c70ca045e40b8820ff58a0328e6e5479"
done
