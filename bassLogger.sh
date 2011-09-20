#!/usr/bin/env bash

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
HOURS=23

output_help(){
  echo "*========================================"
  echo "*  How to use this program see the specs :) "
  echo "*========================================"
  exit ${1}
}


version(){
  echo "${0} is now at ${VERSION}"
  exit 0
}

conditioner(){
 cat ${FILE}  | cut -d ' '  -f1,4,9  | sed -e "s/\[/ /g;s/:/ /g" | tee rajib.txt | awk -v H="${HOURS}" '{ if($3<=H) print $0 }' >> processed_tmp.txt
}



best_attempts(){
  echo "Q1: Most number of connection attempts   "
  echo "========================================="
  #cat ${FILE} | cut -d ' '  -f1 | sort -n | uniq -c | sort -rn >> tmp.txt
  #for i in $( seq $(( ${HOURS} )))
  #do
    #cat tmp.txt | grep -e "[0-9]\{4\}:${i}" > rajib.txt
  #done

  conditioner

  if [ ${HOURS} -lt  24 ]; then
   cat processed_tmp.txt | cut -d " " -f1 | sort -n | uniq -c | sort -rn >> tmp.txt
   rm processed_tmp.txt
  else
    output_help 1
  fi
}



successful_con(){
  echo "Q2: Most number of successful connections"
  echo "========================================="
  conditioner
  if [ ${HOURS} -lt  24 ]; then
    cat processed_tmp.txt |  cut -d " " -f1,7 | tee rajib.txt | grep 200$ | sort -rn | uniq -c | sort -rn >> "tmp.txt"
    rm processed_tmp.txt
  else
    output_help 1
  fi
}


display_results(){
  if [ -n "${LIMIT}" ] ; then
    cat tmp.txt | head -n ${LIMIT}
  else
    if [ -f "tmp.txt" ]; then
      cat tmp.txt
      rm tmp.txt
    else
      output_help 1
    fi
  fi
}


file_or_stdin(){
  # Make sure we get file name as command line argument
  # Else read it from standard input device
  if [ "${FILE}" == "" ]; then
     FILE="/dev/stdin"
  else
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



#using bash getopts
#while getopts ":n:h:d:f c 2 v " opt
#do
  #case ${opt} in
  #n) LIMIT=${OPTARG};;
  #h) echo ${OPTARG} ;;
  #f) FILE=${OPTARG} ;;
  #c) best_attempts ;;
  #2) successful_con ;;
  #v) version ;;
  #esac
#done




# This loop reads all the arguments passsed
# trough the command line
while [ $# -gt 0 ]
do
  case ${1} in
    -n | --number )   shift  ; LIMIT=${1} ;;
    -f | --file   )   shift  ; FILE=${1}  ;;
    -h | --hours )    shift  ; HOURS=${1} ;;
    -v | --version)   version         ;;
    -c )              best_attempts   ;;
    -2 )              successful_con  ;;
    *)  break ;;
  esac
  shift
done

# Actual excution of functions to display data
file_or_stdin
display_results
exit 0
