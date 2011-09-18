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

output_help(){
    echo "usage: bla bla"
}

best_attempts(){
  #echo "Q1: Most number of connection attempts   "
  #echo "========================================="
  #conditional for time parsing
  echo ${lim}
  cat $file | cut -d ' '  -f1 | sort | uniq -c | sort -rn | head -n 10
  #echo "\n\n"
}

successful_con(){
  echo "Q2: Most number of successful connections"
  echo "========================================="

  #conditional for time parsing
  cat $file |  cut -d " " -f1,9 | grep 200$ | sort -rn | uniq -c | sort -rn | head -n 10 | sed "s/200$//"
  echo "\n\n"
}


# $@ is passed here
# $@ is a special vaible that holds the
# seperated
if [ $# -lt 1 ]; then
  output_help
  exit 1
fi

while [ $# -gt 1 ]
do
  echo ${1}
  case ${1} in
    -n)
      lim=${1}
      ;;
    -f) file=${2}
      ;;
    --)
      break
      ;;
    -*)
      echo $0: $1: unrecognized option >&2
      break
      ;;
     *) break
      ;;
  esac
  shift
done

best_attempts
successful_con
