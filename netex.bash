#!/bin/bash

#me being an idjit and cropping an ifconfig instead of hostname -I
ifresult=$(ifconfig)
crop1="${ifresult#*inet}"
crop2="${crop1%%netmask**}"
crop3="${crop2%.*}"

for i in {1..254}
do
  pingadrs="$crop3.$i"
  ping -q -c1 $pingadrs > /dev/null
  if [ $? -eq 0 ]
  then
     hostres=$(host $pingadrs 2> /dev/null)
     if [ $? -ne 0 ]
     then
       hostres="Not Available"
     fi
     nc -zv -w 1 $pingadrs 22 &> /dev/null
     sshres=$?
     nc -zv -w 1 $pingadrs 80 &> /dev/null
     httpres=$?
     if [ $sshres -eq 0 ]
     then
       sshres="open"
     else
       sshres="closed"
            fi
     if [ $httpres -eq 0 ]
     then
       httpres="open"
     else
       httpres="closed"
     fi
     macres=$(arp -a | grep "${pingadrs})")
     macres1="${macres#*at}"
     echo $macres1
     macres2="${macres%%on**}"
     echo $macres2
     echo "hostname: " $hostres ", ip address: " $pingadrs ", mac address" $macres ", ssh port:" $sshres ", http port: " $httpres
  fi
done
