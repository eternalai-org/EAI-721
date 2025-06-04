#!/bin/bash


for i in {6000..6999}
do
  yarn ts:run scripts/nfts/cryptoai/5.mint.ts $i "0x13a077fEe628490824e2326C619aDcA4bDCBCca9" "d9a80277118ae8d457c528bd0b0a6461baa50847b1e4963c625711a86085dcde"
done
