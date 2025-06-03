#!/bin/bash


for i in {3000..3999}
do
  yarn ts:run scripts/nfts/cryptoai/5.mint.ts $i "0x1D272FcA4EAdCc2d68072018A43cDdFfC00cADdE" "521fa203becbca5e5a2fa66731de2d70eef9efa17a2394e9ddc9f17e3f63ec91"
done
