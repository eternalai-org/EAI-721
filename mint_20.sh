#!/bin/bash


for i in {999..900}
do
  yarn ts:run scripts/nfts/cryptoai/5.mint.ts $i "0xD1F7f358C32Ca657B947C86856813Ecd4DfF4f8b" "3dec52a9d872181d85a478f63d9bc5707379e0e2784cc19f92d248162b4d319a"
done
