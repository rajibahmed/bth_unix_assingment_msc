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
FILE=""
LIMIT= # if not capped all info will show

output_help(){
  echo "\n*========================================"
  echo "*  How to use this program see the specs :) "
  echo "*========================================\n"
  exit ${1}
}


version(){
  echo "${0} is now at ${VERSION}"
  exit 0
}


best_attempts(){
  echo "Q1: Most number of connection attempts   "
  echo "========================================="
  cat ${FILE} | cut -d ' '  -f1 | uniq -c | sort -rn >> tmp.txt
}



successful_con(){
  echo "Q2: Most number of successful connections"
  echo "========================================="

  #conditional for time parsing
  cat ${FILE} |  cut -d " " -f1,9 | grep 200$ | sort -rn | uniq -c | sort -rn | sed "s/200$//" >> tmp.txt

}


display_results(){
  if [ -n "${LIMIT}" ] ; then
    cat tmp.txt | head -n ${LIMIT}
  else
    cat tmp.txt
  fi
  rm tmp.txt
}


file_or_stdin(){
  # Make sure we get file name as command line argument
  # Else read it from standard input device
  if [ "$1" == "" ]; then
     FILE="/dev/stdin"
  else
     FILE="${1}"
     # checks file exist and readable
     if [ ! -f ${FILE} ]; then
          echo "${FILE} : does not exists"
          exit 1
     elif [ ! -r ${FILE} ]; then
          echo "${FILE}: can not read"
          exit 2
     fi
  fi
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
  case ${1} in
    -n | --number )   shift  ; LIMIT=${1};;
    -f | --file   )   shift  ; FILE=${1} ;;
    -v | --version)   version         ;;
    -c )              best_attempts   ;;
    -2 )              successful_con  ;;
    -h | --help   )   output_help 0   ;;
    *)  break ;;
  esac
  shift
done

# Actual excution of functions to display data
echo "\n"
display_results
