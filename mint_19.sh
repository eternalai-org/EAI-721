#!/bin/bash


for i in {1999..1000}
do
  yarn ts:run scripts/nfts/cryptoai/5.mint.ts $i "0x5B1BBe37b70ca8159cc32A65E227347644c86640" "6d66c5fbcd87d78861b08ff33dbc2bfce20fd35c780703e900475a9e0116b816"
done
