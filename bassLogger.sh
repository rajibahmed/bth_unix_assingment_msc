#!/bin/sh

#############################################
# This is script for reading webserver log
# and generating report from that with bash
#
# @authors: Rajib Ahmed & Md. Abdur Razzak
# @emails : {raae10,morc10}@students.bth.se
# @version: 1.0.0.dev
#############################################

cat $1 | cut -d ' '  -f1 | sort | uniq -c | sort -rn | tee tmp.txt | head -n 10
