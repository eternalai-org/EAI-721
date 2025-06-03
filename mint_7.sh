#!/bin/bash


for i in {6000..6999}
do
  yarn ts:run scripts/nfts/cryptoai/5.mint.ts $i "0x13a077fEe628490824e2326C619aDcA4bDCBCca9"
done
