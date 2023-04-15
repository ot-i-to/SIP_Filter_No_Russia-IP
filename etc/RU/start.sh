#!/bin/bash

pgrep tail -x || (/bin/tail -F /var/log/BAD_SIP_No_Russia-IPSET.log | /etc/RU/whois.sh &)
