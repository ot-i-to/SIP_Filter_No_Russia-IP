#!/bin/bash

iptables -S
iptables -L -n -v --line-numbers
for i in $(iptables -L -n -v --line-numbers | grep russia_run | awk '{ print $1 }' | sort -rn)
do
    echo "> iptables -D INPUT $i"
    iptables -D INPUT $i
done
iptables -L -n -v --line-numbers
iptables -I INPUT 1 -i eth1 -p udp -m multiport --dports 5040:5090 -m set ! --match-set russia_run src -j LOG --log-prefix "BAD_SIP_No_Russia-IPSET: " --log-level 6
iptables -I INPUT 2 -i eth1 -p udp -m multiport --dports 5040:5090 -m set ! --match-set russia_run src -j DROP
iptables -L -n -v --line-numbers




