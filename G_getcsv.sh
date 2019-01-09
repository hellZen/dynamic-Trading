#!/bin/bash
 echo enter ticker name
 read fname

awk -F "," '{print $1","$2","$3","$4","$5","$6","$7}' ./dat2.txt >$fname.csv
echo "$fname.csv was created"


:
