#!/bin/sh

#############################################
# This is script for reading webserver log
# and generating report from that with bash
#
# @authors: Rajib Ahmed & Md. Abdur Razzak
# @emails : {raae10,morc10}@students.bth.se
# @version: 1.0.0.dev
#############################################

#default variables
n=20

#set -- `getopt hn: $*`

#for option in $*
#do
  #echo ${option}
#done


bestAttempts(){
  #echo "Q1: Most number of connection attempts   "
  #echo "========================================="

  #conditional for time parsing
  cat $1 | cut -d ' '  -f1 | sort | uniq -c | sort -rn | head -n 10
  #echo "\n\n"
}

successfulConnection(){
  echo "Q2: Most number of successful connections"
  echo "========================================="

  #conditional for time parsing
  cat $1 |  cut -d " " -f1,9 | grep 200$ | sort -rn | uniq -c | sort -rn | head -n 10 | sed "s/200$//"
  echo "\n\n"
}

bestAttempts $1
#successfulConnection $1
