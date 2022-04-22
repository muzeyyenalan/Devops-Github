#!/bin/bash
echo enter sayi
read sayi
num=0
while [ $sayi -gt 0 ]
do
num=$(expr $num \* 10)
k=$(expr $sayi % 10)
num=$(expr $num + $k)
sayi=$(expr $sayi / 10)
done
echo number is $num
