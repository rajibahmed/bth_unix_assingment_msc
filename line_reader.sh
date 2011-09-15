#!/bin/bash
 
# User define Function (UDF)
processLine(){
  line="$@" # get all args
  #  just echo them, but you may need to customize it according to your need
  # for example, F1 will store first field of $line, see readline2 script
  # for more examples
  # F1=$(echo $line | awk '{ print $1 }')
  
  lower=$( echo $line | cut -d" " -f1 )
  upper=$( echo $line | cut -d" " -f2 )
    
  li=$( echo $lower | cut -d\. -f1 )
  lj=$( echo $lower | cut -d\. -f2 )
  lk=$( echo $lower | cut -d\. -f3 )
  ll=$( echo $lower | cut -d\. -f4 )
  
  ui=$( echo $upper | cut -d\. -f1 )
  uj=$( echo $upper | cut -d\. -f2 )
  uk=$( echo $upper | cut -d\. -f3 )
  ul=$( echo $upper | cut -d\. -f4 )
  
  tempI=$(( $li ))
  while [ "$li" -le $ui ]
  do
    tempJ=$(( $lj ))
    while [ "$lj" -le $uj ]
    do
      tempK=$(( $lk ))
      while [ "$lk" -le $uk ]
      do
        tempL=$(( $ll ))
        while [ "$ll" -le $ul ]
        do
          echo -n "Testing .... $li.$lj.$lk.$ll"
          noreply=`ping -s 300 -c 1 $li.$lj.$lk.$ll | grep -c "0 received"`
          if [ $noreply -eq "1" ]; then
            echo " ===> No replys"
          else
            echo " ===> proceeding"
            resolveip $li.$lj.$lk.$ll | cut -d' ' -f 4,6 >> hostnames
            ping -s 1400 -c 5 $li.$lj.$lk.$ll >> ping.result
            echo -n "$li.$lj.$lk.$ll " >> ping.mapping
            echo -n "$li.$lj.$lk.$ll " >> ping.time
            date >> ping.time
            cat ping.result | grep time= | gawk '{print $7}' | sort | tr '=' ' ' | gawk '{print $2}' | sed -n '3p' | tr '\n' ' ' >> ping.mapping
          fi
          ll=$(( $ll+1 ))
        done
        ll=$(( $tempL ))
        lk=$(( $lk+1 ))
      done
      lk=$(( $tempK ))
      lj=$(( $lj+1 ))
    done
    lj=$(( $tempJ))
    li=$(( $li+1 ))
  done
  li=$(( $tempI ))
}
 
### Main script stars here #IP_ARR=$(echo $IPSTR | tr "." " ")
##
# Store file name
FILE=""
 
# Make sure we get file name as command line argument
# Else read it from standard input device
if [ "$1" == "" ]; then
   FILE="/dev/stdin"
else
   FILE="$1"
   # make sure file exist and readable
   if [ ! -f $FILE ]; then
  	echo "$FILE : does not exists"
  	exit 1
   elif [ ! -r $FILE ]; then
  	echo "$FILE: can not read"
  	exit 2
   fi
fi
# read $FILE using the file descriptors
 
# Set loop separator to end of line
BAKIFS=$IFS
IFS=$(echo -en "\n\b")
exec 3<&0
exec 0<"$FILE"
while read -r line
do
	# use $line variable to process line in processLine() function
	processLine $line
done
exec 0<&3
 
# restore $IFS which was used to determine what the field separators are
IFS=$BAKIFS
exit 0
