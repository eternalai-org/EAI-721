#!/bin/bash


for i in {3999..3000}
do
  yarn ts:run scripts/nfts/cryptoai/5.mint.ts $i "0x37141e8a75D0a978aa95D95892643e506b942bf7" "342c37afe757352e22354fbe5b3daac0783b5833b6a6b46dea2fb13ecb988d0b"
done
