#!/bin/sh

#############################################
# This is script for reading webserver log
# and generating report from that using
# shell scripting
#
# @authors: Rajib Ahmed & Md. Abdur Razzak
# @emails : {raae10,morc10}@students.bth.se
# @version: 1.0.0.dev
#############################################

#default variables
VERSION="1.0.0.dev"
lim=20

#set -- `getopt hn: $*`

output_help(){
  echo "usage: options [n|h|f]"
  exit ${1}
}



version(){
  echo "${0} is now at ${VERSION}"
  exit 0
}


best_attempts(){
  echo "Q1: Most number of connection attempts   "
  echo "========================================="
  #conditional for time parsing
  cat $file | cut -d ' '  -f1 | sort | uniq -c | sort -rn | head -n ${lim}
  echo "\n"
}



successful_con(){
  echo "Q2: Most number of successful connections"
  echo "========================================="

  #conditional for time parsing
  cat $file |  cut -d " " -f1,9 | grep 200$ | sort -rn | uniq -c | sort -rn | head -n ${lim} | sed "s/200$//"
  echo "\n"
}




# $@ is passed here
# $@ is a special vaible that holds the
# seperated
if [ $# -lt 1 ]; then
  output_help 1
fi

while [ $# -gt 0 ]
do
  case ${1} in
    -n | --number )   lim=${2}    ; shift  ;;
    -f | --file   )   file=${2}   ; shift  ;;
    -v | --version)   version     ;;
    -h | --help   )   output_help 0 ;;
    -*) echo $0: $1: unrecognized option >&2 ;;
     *) break   ;;
  esac
  shift
done

echo "\n"
best_attempts
successful_con
