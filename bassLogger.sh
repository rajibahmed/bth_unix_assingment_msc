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
DAYS=0

output_help(){
  echo "*============================================================="
  echo "  This is how you use this application  :"
  echo "  params sequence is important to run the application properly "
  echo "  script_name -f [FILENAME] -[n|h|d] -[c|r|2|t|F] "
  echo -e "  the last argument is ignored .... file name should be \n passed as value to f flag"
  echo "============================================================="
  exit ${1}
}


version(){
  echo "${0} is now at ${VERSION}"
  exit 0
}

processed_by_date(){
  last_date=`cat ${FILE} | tail -1 | cut -d " " -f4 | sed -e "s/\[//g" | cut -d ":" -f1 | sed -e "s/\// /g"`

  the_date=`echo $last_date | sed -e "s/ /\//g"`


  if [ -f 'tmpfile' ];then
    rm 'tmpfile'
  fi

  if [ "${DAYS}" -gt 0 ]; then
    cat 'processed_tmp.txt' | grep -e "$the_date" >> tmpfile
    for day in `seq ${DAYS}`
    do
       find_date=` date --date="${last_date} ${day} day ago" '+%d/%b/%Y'`
       cat 'processed_tmp.txt' | grep -e "$find_date" >> tmpfile
    done
    cat tmpfile > 'processed_tmp.txt'
  fi
}

processed_by_hours(){
  if [  "${HOURS}" -gt 0  ]; then
    cat ${FILE}  | cut -d ' '  -f1,4,9,10  | sed -e "s/\[/ /g;s/:/ /g" | awk -v H="${HOURS}" '{ if($3<=H) print $0 }' > 'processed_tmp.txt'
  fi
}


conditioner(){
    #When only one params is availible
    processed_by_hours
    processed_by_date
}



best_attempts(){
  #echo "Q1: Most number of connection attempts   "
  #echo "========================================="

  conditioner
  cat processed_tmp.txt | cut -d " " -f1 | sort -n | uniq -c | sort -rn | awk '{ print $2 "\t" $1 }'> tmp.txt

}



successful_con(){
  #echo "Q2: Most number of successful connections"
  #echo "========================================="
  conditioner
  cat processed_tmp.txt |  cut -d " " -f1,7  | grep 200$ | sort -rn | uniq -c | sort -rn | awk '{ print $1 "\t" $2 }' > "tmp.txt"
}


common_code_from_ips(){
  #echo "Q3: Most common status code and uniq ips on that status code"
  #echo "============================================================"

  conditioner
  cat processed_tmp.txt |  cut -d " " -f7  | sort -rn | uniq -c | sort -rn | head -n 1 | cut -d " " -f4 | grep -f - processed_tmp.txt | cut -d " " -f1,7 | uniq | awk '{ print $2 "\t" $1 }'> tmp.txt
}



common_faliure_code_from_ips(){
#  echo "Q4: Most status code 400-599 and uniq ips on that status code"
  #echo "============================================================"

  conditioner
  cat processed_tmp.txt |  cut -d " " -f7  | sort -rn | uniq -c | grep "[4-5][0-9]\{2\}$" | awk '{ print " "$2 }' |  grep -f - processed_tmp.txt  | cut -d " " -f1,7 | sort -rn | uniq | awk '{ print $2 "\t" $1 }'> tmp.txt
}



most_bytes_sent(){
  #echo "Q5: Most bytes sent to ips"
  #echo "============================================================"

  conditioner

  if [ -f 'tmpfile' ]; then
    rm 'tmpfile'
  fi

  #wierd :)
  for ip in ` cat 'processed_tmp.txt' | cut -d " " -f1 | sort -rn | uniq `
  do
    sum=0
    for line in ` cat 'processed_tmp.txt' | grep -e "${ip}" | cut -d " " -f1,8 | sed -e "s/-/0/g;s/ /-/g"`
    do
      bytes=`echo $line | cut -d "-" -f2 `
      sum=$(( ${sum}+${bytes} ))
    done
    echo "${ip} ${sum}"  >> 'tmpfile'
  done
  cat 'tmpfile' | sort -k 2 -rn > 'tmp.txt'
}


display_results(){
  if [ -n "${LIMIT}" ] ; then
    cat tmp.txt | head -n ${LIMIT}
  else
    if [ -f "tmp.txt" ]; then
      cat tmp.txt
    else
      output_help 1
    fi
  fi

  if [ -f "tmp.txt" ]; then
    rm tmp.txt
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
    -d | --days  )    shift  ; DAYS=${1}  ;;
    -v | --version)   version         ;;
    -c )              best_attempts   ;;
    -2 )              successful_con  ;;
    -r )              common_code_from_ips  ;;
    -F)               common_faliure_code_from_ips ;;
    -t)               most_bytes_sent ;;
    *)break ;;
  esac
  shift
done

# Actual excution of functions to display data
file_or_stdin
display_results
exit 0
