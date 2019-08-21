#! /bin/sh

cd levels
./lvloffs.sh
cd ..
z80asm main.asm
bin2tap -a 33280 a.bin
cat loader.tap a.tap levels/page0.tap levels/page1.tap levels/page3.tap levels/page4.tap levels/page6.tap levels/page7.tap > 'SLAM+ris.tap'
