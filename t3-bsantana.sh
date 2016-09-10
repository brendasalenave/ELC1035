#!/bin/bash

field1=(${field1[*]} `sed '/^#/ d' $1 | cut -f1 -d' '`)
field2=(${field2[*]} `sed '/^#/ d' $1 | cut -f2 -d' '`)
field3=(${field3[*]} `sed '/^#/ d' $1 | cut -f3 -d' '`)
field4=(${field4[*]} `sed '/^#/ d' $1 | cut -f4 -d' '`)
field5=(${field5[*]} `sed '/^#/ d' $1 | cut -f5 -d' '`)

echo -e "#
# Delegated nameserver records (someone else provides the SOA)
#
#   &fqdn:ip:x:ttl =>
#
#	NS record x.ns.fqdn as nameserver for fqdn
#	A record mapping x.ns.fqdn -> ip [if ip present]
&10.in-addr.arpa::dns-int.inf.ufsm.br.
&42.18.200.in-addr.arpa::dns-int.inf.ufsm.br.
cd&inf.ufsm.br::dns-int.inf.ufsm.br.
#" > dns.conf

for i in ${!field1[@]}; do
  echo -e "=${field1[$i]}.inf.ufsm.br:${field2[$i]}"
  if [[ ${field5[$i]} != "-" ]] ; then
    echo -e "C${field5[$i]}.inf.ufsm.br:${field1[$i]}.inf.ufsm.br"
  fi
done >> dns.conf

########################################################################## DHCPD ######################################################################################

echo -e "####################
## Global options ##
####################

not authoritative;" > dhcpd.conf



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
