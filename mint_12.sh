#!/bin/bash


for i in {6999..6000}
do
  yarn ts:run scripts/nfts/cryptoai/5.mint.ts $i "0x212aab4bfdec109b1e3357b29b007f8e4d9df3f5" "3548a3a94a7acefefc4ab8cba2d0e76838652454b129aaae80e58416e7b56fdd"
done
