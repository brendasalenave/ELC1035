#!/bin/bash

field1=(${field1[*]} `sed '/^#/ d' $1 | cut -f1 -d' '`)
field2=(${field2[*]} `sed '/^#/ d' $1 | cut -f2 -d' '`)
field3=(${field3[*]} `sed '/^#/ d' $1 | cut -f3 -d' '`)
field4=(${field4[*]} `sed '/^#/ d' $1 | cut -f4 -d' '`)
field5=(${field5[*]} `sed '/^#/ d' $1 | cut -f5 -d' '`)
f2=(${f2[*]} `sed '/^#/ d' $1 | cut -f2 -d' ' | cut -f1,2,3 -d'.' | sort -n |uniq`)

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
    echo -e "C${field5[$i]}.inf.ufsm.br:${field1[$i]}.inf.ufsm.br."
  fi
done >> dns.conf

########################################################################## DHCPD ######################################################################################

echo -e "
####################
## Global options ##
####################

not authoritative;

option domain-name "inf.ufsm.br";
option domain-name-servers 200.18.42.3;
option subnet-mask 255.255.255.0;

default-lease-time 7200;
max-lease-time 7200;

ddns-update-style none;

shared-network inf-ufsm-br {
# internal IPs" > dhcpd.conf


g=(${g[*]} `sed -n -e '/^# [A-Z|h]/ d' -e '/^# [a-z]/p' $1`)
groups=(${groups[*]} `echo ${g[*]/"#"}`)
#for i in ${groups[@]} ; do echo -e "$i" ; done

#echo "${groups[*]}"

#for i in ${groups[@]} ; do

for ((u = 0; u < ${#f2[@]}; u++)) ; do
  echo -e "\tsubnet ${f2[$u]}.0 netmask 255.255.255.0\t{"
  if [[ $u == 0 ]] ; then
    echo -e "\t\tnot authoritative;\n\t\toption routers 10.1.1.1;\n\t\toption broadcast-address 10.1.1.255;\n\t\toption subnet-mask 255.255.255.0;\n\t\toption domain-name-servers 200.18.42.3;\n"
  else
    echo -e "\t\tauthoritative;\n\t\toption routers 200.18.42.7;\n\t\toption broadcast-address 200.18.42.255;\n\t\toption subnet-mask 255.255.255.0;\n"
  fi
  for ((i = 0; i < ${#groups[@]}; i++)) ; do
    #echo -e "\t\t# group ${groups[$i]}"
    echo -ne "\t\tgroup {"
    for ((j = 0; j < ${#field1[@]}; j++)) ; do
      if [[ "${field4[$j]}" == "${groups[$i]}" && "${field2[$j]}" =~ "${f2[$u]}" ]]; then
        f3=(`echo ${field3[$j]} | sed 's/,/ /g' | cut -f1,2,3 -d' '`)
        for ((k = 0; k < ${#f3[@]}; k++)) ; do
          if [[ $k == 0 ]] ; then
            echo -ne "\n\t\t\thost ${field1[$j]} { hardware ethernet ${f3[$k]}; fixed-address ${field2[$j]}; }"
          else
            echo -ne "\n\t\t\thost ${field1[$j]}$k { hardware ethernet ${f3[$k]}; fixed-address ${field2[$j]}; }"
          fi
        done
      fi
    done
    echo -e " }\r"
  done
  echo -e "\t}"
done >> dhcpd.conf
echo "}" >> dhcpd.conf

sed -i -e 's/group { }//g' -e 's/} }/}\n\t\t}/g' -e '/^\s*$/d' -e '/^$/d' dhcpd.conf
