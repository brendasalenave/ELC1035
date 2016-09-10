#!/bin/bash

#$1="t2-input-example.txt"

if [ $# -eq 0 ]; then
 echo "Error - no Parameter"
else
  #echo "File parameter is: $1"
  IFS=$'\n';
  # Sort by login (alphabetical order)"
  echo -e "Task 1:"
  array=( $(sort -u -k1 $1 | cut -f2 -d'|') )
  for i in ${array[@]} ; do echo -e "\t$i" ; done

  # Sort by name
  echo -e "\nTask 2:"
  array=( $(sort -u -t'|' -k2 $1 | cut -f2 -d'|') )
  for i in ${array[@]} ; do echo -e "\t$i" ; done

  # Aggregate by group, and sort by name (reverse order)"
  echo -e "\nTask 3:"
  sorted=(${sorted[*]} `cut -d'|' -f2,3 $1 | sort -r -u | uniq`)
  info=`cut -d'|' -f2,3 $1 |sort`
  groups=(${groups[*]} `echo "$info"| cut -f2 -d'|' | sort | uniq`)

  for i in ${groups[@]} ; do
    echo -e "\t$i:" ;
    for j in ${sorted[@]} ; do
      a=$(echo "$j" |cut -d'|' -f2)
      if [ $i == $a ] ; then
          echo -e "\t\t$(echo "$j" |cut -d'|' -f1)"
      fi
    done
  done

 # Sort by age (numerical order)
  echo -e "\nTask 4:"
  array=( $(sort -n -t'|' -k4 $1 | cut -f2 -d'|') ); for i in ${array[@]} ; do echo -e "\t$i" ; done

  echo -e "\nTask 5:"
  array=( $(cut -f2 -d'|' $1 | sort -u -t' ' -k3) ); for i in ${array[@]} ; do echo -e "\t$i" ; done

fi
