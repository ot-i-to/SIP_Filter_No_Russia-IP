#!/bin/bash

#pgrep tail -x || (/bin/tail -F /var/log/messages | /bin/grep BAD_SIP_No_Russia-IPSET | /etc/RU/whois.sh &)
pgrep tail -x || (/bin/tail -F /var/log/BAD_SIP_No_Russia-IPSET.log | /etc/RU/whois.sh &)
