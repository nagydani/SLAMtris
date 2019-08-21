#! /bin/bash

PG=16
ADDR=65024
cat *lzx > lvls.dat
OFF=1
LEN=512
for I in 0 1 3 4 6 7
do
	tail -c+$OFF lvls.dat | head -c $LEN > "page$I.bin"
	bin2tap -a $ADDR "page$I.bin" -o "page$I.tap"
	rm "page$I.bin"
	ADDR=49152
	OFF=`expr $OFF + $LEN`
	LEN=16384
done
rm lvls.dat
ADDR=65024
> lvloffs.asm
for I in *lzx
do
	printf '\tdefb\t$%02X\n\tdefw\t$%04X\n' $PG $ADDR >> lvloffs.asm
	LEN=`wc -c $I | cut -d' ' -f1`
	ADDR=`expr $ADDR + $LEN`
	if [ $ADDR -gt 65535 ]
	then
		ADDR=`expr $ADDR - 16384`
		PG=`expr $PG + 1`
		if [ $PG == 18 ]
		then
			PG=`expr $PG + 1`
		fi
		if [ $PG == 21 ]
		then
			PG=`expr $PG + 1`
		fi
	fi
done
printf '\tdefb\t$%02X\n\tdefw\t$%04X\n' $PG $ADDR >> lvloffs.asm
