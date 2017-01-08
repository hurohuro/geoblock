#!/bin/bash

echo "$0 Start."

cd /tmp

wget http://www.ipdeny.com/ipblocks/data/countries/all-zones.tar.gz 2> /dev/null
tar zxf all-zones.tar.gz
rm -f jp.zone bg.zone

firewall-cmd --permanent --direct --remove-rules ipv4 filter INPUT
firewall-cmd --reload

ipset destroy geoblock
ipset create geoblock hash:net maxelem 262144

for file in *.zone; do
  for line in `cat $file`; do
    ipset add geoblock $line
  done
done

rm -f *.zone all-zones.tar.gz*

firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 0 -m set --match-set geoblock src -j DROP
firewall-cmd --reload

echo "$0 Done."
