#!/bin/bash

PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
export PATH

IPSET=/usr/sbin/ipset
IPNEW=/etc/RU/ip.new
IPSETADD=/etc/RU/ipset.add
COUNT=0
MASK=" "
COUNTRY=" "

if [[ -f /etc/RU/$(date -d '1 day ago' "+%Y-%m-%d")-count.whois ]]; then
    rm -f /etc/RU/$(date -d '1 day ago' "+%Y-%m-%d")-count.whois
fi

if [[ ! -f /etc/RU/$(date "+%Y-%m-%d")-count.whois ]]; then
    echo 0 > /etc/RU/$(date "+%Y-%m-%d")-count.whois
fi

funFCOUNT() {
    if [[ -f /etc/RU/$(date "+%Y-%m-%d")-count.whois ]]; then
	echo $(($(cat /etc/RU/$(date "+%Y-%m-%d")-count.whois) + 1)) > /etc/RU/$(date "+%Y-%m-%d")-count.whois
    else
	echo 1 > /etc/RU/$(date "+%Y-%m-%d")-count.whois
    fi
    COUNT=$(cat /etc/RU/$(date "+%Y-%m-%d")-count.whois)
}

funWHOIS() {
	rm -f /tmp/*.whois
	whois $IP > /tmp/$IP.whois
	COUNTRY=$(cat /tmp/$IP.whois | grep -iE "^Country:" | sed s/'[cC]ountry:'// | sed s/' '//g | sed -n '$p')
	MASK=$(cat /tmp/$IP.whois | grep -iE "^CIDR:|^route:" | sed s/'^CIDR:'// | sed s/'^[rR]oute:'// | sed s/' '//g | sed -n '$p')
}

funIPSET() {
	if [[ $COUNTRY = 'RU' ]] || [[ $COUNTRY = 'ru' ]] || [[ $COUNTRY = 'Ru' ]]; then
	    if [[ $($IPSET list russia_run | grep -c $MASK) = 0 ]]; then
		if $IPSET -q add russia_run $MASK; then
			echo "$(date +'%x %T ') [$COUNT] ADD Russian MASK: $MASK" >> $IPSETADD
		fi
	    fi
	fi
}

while read line; 
do
    ## IP=$(echo $line | awk '{ print $11}' | sort | uniq | sed 's/SRC=//' | sed s/' '//g )
    IP=$(echo $line | awk '{for(k=NF; k>0; --k) {if ($k ~ /SRC=/) print $k}}' | sed 's/SRC=//')
    ## echo $IP >> /tmp/ip.log
    if [[ -f $IPNEW ]]; then
	if [[ $(grep -c $IP $IPNEW) = 0 ]]; then
	    funFCOUNT
	    if [[ $COUNT < 901 ]]; then
		funWHOIS
#		echo "$(date +'%x %T ') [$COUNT] New No Russian IP: $IP COUNTRY: $COUNTRY MASK: $MASK"
		echo "$(date +'%x %T ') [$COUNT] New No Russian IP: $IP COUNTRY: $COUNTRY MASK: $MASK" >> $IPNEW
		funIPSET
	    else
		echo "$(date +'%x %T ') [$COUNT] New No ADD Russian IP: $IP COUNTRY: $COUNTRY MASK: $MASK --> limit search whois info !" >> $IPNEW
	    fi
#	else
#	    COUNT=$(cat $(date "+%Y-%m-%d")-count.whois)
#	    echo "$(date +'%x %T ') [$COUNT] YES -> $IP"
	fi
    else
	funFCOUNT
	if [[ $COUNT < 901 ]]; then
	    funWHOIS
#	    echo "$(date +'%x %T ') [$COUNT] New No Russian IP: $IP COUNTRY: $COUNTRY MASK: $MASK"
	    echo "$(date +'%x %T ') [$COUNT] New No Russian IP: $IP COUNTRY: $COUNTRY MASK: $MASK" >> $IPNEW
	    funIPSET
	fi
    fi
done

