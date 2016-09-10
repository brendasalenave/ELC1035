#!/bin/bash

array=(${array[*]} `sed '/^#/ d' $1 | cut -f1,2 -d' '`)
#for i in ${array[@]} ; do echo -e "$i" ; done

field1=(${field1[*]} `sed '/^#/ d' $1 | cut -f1 -d' '`)
field2=(${field2[*]} `sed '/^#/ d' $1 | cut -f2 -d' '`)
field3=(${field3[*]} `sed '/^#/ d' $1 | cut -f3 -d' '`)
field4=(${field4[*]} `sed '/^#/ d' $1 | cut -f4 -d' '`)

for i in ${!field1[@]}; do echo -e "=${field1[$i]}.inf.ufsm.br:${field2[$i]}" ; done > dns.conf

########################################################################## DHCPD ######################################################################################

g=(${g[*]} `sed -n -e '/^# [A-Z|h]/ d' -e '/^# [a-z]/p' $1`)
groups=(${groups[*]} `echo ${g[*]/"#"}`)
#for i in ${groups[@]} ; do echo -e "$i" ; done

#echo "${groups[*]}"

#for i in ${groups[@]} ; do

for ((i = 0; i < ${#groups[@]}; i++)) ; do
  echo -e "\tgroup {"
  #for i in ${!field1[@]}; do echo -e "\thost ${field1[$i]} ethernet ${field3[$i]}; fixed-address ${field2[$i]}" ; done
  #for j in ${field1[@]} ; do
  for ((j = 0; j < ${#field1[@]}; j++)) ; do
    if [[ "${field4[$j]}" =~ "${groups[$i]}" ]]; then
        echo -e "\t\thost ${field1[$j]} { hardware ethernet ${field3[$j]}; fixed-address ${field2[$j]}; }"
    fi
  done
  echo -e "\t}"
done
