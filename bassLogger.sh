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
  cat $file | cut -d ' '  -f1 | sort | tee "test.txt" | uniq -c | sort -rn | head -n ${lim}
}



successful_con(){
  echo "Q2: Most number of successful connections"
  echo "========================================="

  #conditional for time parsing
  cat $file |  cut -d " " -f1,9 | grep 200$ | sort -rn | uniq -c | sort -rn | head -n ${lim} | sed "s/200$//"
}




# program exits when no
# arguments are passed
if [ $# -lt 1 ]; then
  output_help 1
fi



# This loop reads all the arguments passsed
# trough the command line
while [ $# -gt 0 ]
do
  echo ${1}
  echo ${2}
  case ${1} in
    -n | --number )   lim=${2}    ; shift  ;;
    -f | --file   )   file=${2}   ; shift  ;;
    -v | --version)   version         ;;
    -c )              best_attempts   ;;
    -2 )              successful_con  ;;
    -h | --help   )   output_help 0   ;;
    -*) echo $0: $1: unrecognized option >&2 ;;
     *) break   ;;
  esac
  shift
done

# Actual excution of functions to display data
echo "\n"
