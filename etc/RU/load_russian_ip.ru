#!/bin/sh
#####################################################################################################################################################################
# apt-get install ipset libnet-cidr-perl jq
# -------------------------------------------------------------------------------------------------------------------------------------------------------------------
# IPTABLES:
# -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
# -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
# -A INPUT -i lo -j ACCEPT
# -A INPUT -s 127.0.0.0/8 -j ACCEPT
# -A INPUT -p gre -j ACCEPT
# -A INPUT -p icmp -j ACCEPT
# -A INPUT -i eth0 -s 10.0.0.0/8 -p udp -m udp --dport 5000:50000 -j ACCEPT
# -A INPUT -i eth0 -s 172.16.0.0/12 -p udp -m udp --dport 5000:50000 -j ACCEPT
# -A INPUT -i eth3.216 -s 10.0.0.0/8 -p udp -m udp --dport 5000:50000 -j ACCEPT
# -A INPUT -i eth3.216 -s 172.16.0.0/12 -p udp -m udp --dport 5000:50000 -j ACCEPT
# --- Permit IP Clienta ----
# -A INPUT -s 46.4.36.194/32 -p udp -m udp --dport 5000:50000 -j ACCEPT
# --------------------------
# -A INPUT -i eth0 -p udp -m multiport --dports 5000:50000 -m set ! --match-set russia_run src -j LOG --log-prefix "BAD_SIP_No_Russia-IPSET: " --log-level 6
# -A INPUT -i eth3.216 -p udp -m multiport --dports 5000:50000 -m set ! --match-set russia_run src -j LOG --log-prefix "BAD_SIP_No_Russia-IPSET: " --log-level 6
# -A INPUT -i eth0 -p udp -m multiport --dports 5000:50000 -m set ! --match-set russia_run src -j DROP
# -A INPUT -i eth3.216 -p udp -m multiport --dports 5000:50000 -m set ! --match-set russia_run src -j DROP
#####################################################################################################################################################################

echo "[start]"

IPTABLES=/sbin/iptables
IPSET=/usr/sbin/ipset
WGET=/usr/bin/wget
EGREP=/bin/egrep
GREP=/bin/grep
CAT=/bin/cat
SED=/bin/sed
CURL=/usr/bin/curl
GZIP=/bin/gzip
#IPCALC=/usr/bin/ipcalc
IPCALC=/etc/RU/ipcalc.pl
JQ=/usr/bin/jq

BDDIR=/etc/RU
timestamp=$(date "+%Y-%m")
FILE=$BDDIR/$timestamp-ipcalc.ipv4
#FIPSET=$BDDIR/$timestamp-ipset_ru.ipv4
FIPSET=/var/log/ipset_ru-$timestamp.ipv4

echo "[1]"
cd $BDDIR
#1#$WGET -q "https://download.db-ip.com/free/dbip-country-lite-$timestamp.csv.gz" -O- | \
#1#    $GZIP -cd >$timestamp-dbip-country-lite.csv && $CAT $timestamp-dbip-country-lite.csv | \
#1#    $GREP ',RU' | $SED 's/\,RU//g' | $SED 's/\,/-/g' | $GREP '\.' > $FILE

#2#$WGET -q "http://www.ipdeny.com/ipblocks/data/countries/ru.zone" -O $FIPSET

	if [ -s $FIPSET ]; then
	    rm -f $FIPSET
	fi

	if [ -s $FIPSET.tmp ]; then
	    rm -f $FIPSET.tmp
	fi
	
	$CURL -k http://stat.ripe.net/data/country-resource-list/data.json?resource=ru | $JQ -c '.data.resources.ipv4[]' | $SED 's/\"//g' > $FIPSET.tmp
	if [ -s $FIPSET.tmp ]; then
	    for i in $(cat $FIPSET.tmp)
	    do
		echo "> $i"
		$IPCALC -b $i | $GREP '/' | $GREP -v 'Class' | awk '{print $2}' >> $FIPSET
	    done
	    rm -f $FIPSET.tmp
	else
	    exit -1
	fi

#1#if [ -f $FILE ]; then
#1#    if [ -s $FILE ]; then
#1#	echo "[2]"
#1#	/usr/bin/perl -MNet::CIDR=range2cidr -lne 'print for range2cidr $_' $FILE > $FIPSET

	if [ -f $FIPSET ]; then
	    if [ -s $FIPSET ]; then

		echo "[3]"
		$IPSET -q create russia_run hash:net
		echo "[4]"
		$IPSET -q create russia_old hash:net
		echo "[5]"
		$IPSET -q flush russia_old
		echo "[6]"
		$IPSET -q swap russia_run russia_old
		echo "[7]"
		for ippermitir in $($CAT $FIPSET)
		do
		    $IPSET -q add russia_run $ippermitir
		done
		echo "[8]"
		$IPSET -q add russia_run 10.0.0.0/8
		$IPSET -q add russia_run 172.16.0.0/12
		$IPSET -q add russia_run 192.168.0.0/16

#		$IPSET add russia_run 95.47.180.0/22
#		$IPSET add russia_run 45.137.104.0/24
#		$IPSET add russia_run 93.171.32.0/23
#		$IPSET add russia_run 178.170.206.0/24
#		$IPSET add russia_run 185.43.8.0/22
#		$IPSET add russia_run 31.148.12.0/22
#		$IPSET add russia_run 176.118.212.0/24
#		$IPSET add russia_run 185.164.149.0/24
#		$IPSET add russia_run 46.243.179.0/24
#		$IPSET add russia_run 195.211.120.0/24
#		$IPSET add russia_run 77.243.83.0/24
#		$IPSET add russia_run 95.46.120.0/23
#		$IPSET add russia_run 46.8.32.0/24
#		$IPSET add russia_run 194.87.92.0/22
#		$IPSET add russia_run 178.219.36.0/23
#		$IPSET add russia_run 37.230.147.0/24
#		$IPSET add russia_run 176.96.229.0/24
#		$IPSET add russia_run 92.253.219.0/24
#		$IPSET add russia_run 141.101.178.0/24
#		$IPSET add russia_run 109.248.245.0/24
#		$IPSET add russia_run 93.170.246.0/23
#		$IPSET add russia_run 109.248.225.0/24
#		$IPSET add russia_run 109.248.245.0/24
#		$IPSET add russia_run 109.248.61.0/24
#		$IPSET add russia_run 93.170.246.0/23

	    fi
	fi

#1#    fi
#1#fi

echo "[stop]"
exit 0
