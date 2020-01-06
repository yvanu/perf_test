#!/bin/bash
#
# This script used to test network bandwidth and ceph cluster iops & bandwidth.
#
# This script is only for PoC, not for implement.
#
# This script is made by shaoyoufeng, if you have some question or new demand, please call +86-18658845351 or send E-mail to youfeng.shao@zstack.io.
#
#/***************************************************************************
# * This software is for free
# *
# * You may opt to use, copy, modify, merge, publish, distribute and/or sell
# * copies of the Software
# *
# ***************************************************************************/
iodepth=64  #Please modify according to the environment
runtime=10  #Please modify according to the environment
numjobs=4  #Please modify according to the environment
ip="${2} ${3}"  #Please modify according to the environment
date=${1}  #Please modify according to the environment
disk=${4}  #Please modify according to the environment

#[[ ! -f /root/.ssh/id_rsa.pub ]] && echo "ssh public key authentication is not enable, please make it first....."&& exit 1

iperf3-start()
{
#check if iperf3 has been installed
# start iperf3 server
for i in $ip
do
 echo -e "start iperf3 server in $i....." | tee -a /root/PycharmProjects/p_test/logs/$date.txt
 ping -c 2 $i > /dev/null
 if [[ $? == 1 ]]
 then
  echo -e "\033[31m\033[05m$i is down, skip.....\033[0m"
  continue
 fi
 ssh -o "StrictHostKeyChecking no" $i "which iperf3 &>/dev/null" &>/dev/null
 RESULT=`echo $?`
 if [[ $RESULT == 1 ]]
  then
  echo -e "\033[31m\033[05miperf3 has not been installed at host $i, please install it first...\033[0m"
  exit 1
 else
  ssh -o "StrictHostKeyChecking no" $i "iperf3 -s -D &" &>/dev/null
  ssh -o "StrictHostKeyChecking no" $i "iptables -I INPUT -p tcp --dport 5001 -j ACCEPT" &>/dev/null
  echo -e "iperf3 server in $i has been on....."
  sleep 1
 fi
done
}


iperf3-stop()
{
# kill iperf3 server process...
for i in $ip
do
 echo -e "stop iperf3 server in $i....." | tee -a /root/PycharmProjects/p_test/logs/$date.txt
 ping -c 2 $i > /dev/null
 if [[ $? == 1 ]]
 then
  echo -e "\033[31m\033[05m$i is down, skip.....\033[0m"
 continue
fi
 iperf3pid=`ssh -o "StrictHostKeyChecking no" $i 2>/dev/null ps aux | grep iperf3 | grep ? | head -n 1| awk -F ' ' '{print $2}'`
 ssh -o "StrictHostKeyChecking no" $i kill -9 $iperf3pid &>/dev/null
 ssh -o "StrictHostKeyChecking no" $i "iptables -D INPUT -p tcp --dport 5001 -j ACCEPT" &>/dev/null
 echo -e "iperf3 server on $i bas been off....."
done
echo -e "============================================================================"
}


band()
{
# start to test bandwidth of network
# please replace the network as your enviroment
echo -e "\e[1mstart to test bandwidth of network.....\e[0m"
for i in $ip
do
 for j in $ip
 do
  if [[ $i != $j ]]
   then
    echo -e "$i send data to $j..." | tee -a /root/PycharmProjects/p_test/logs/$date.txt
    ping -c 2 $i > /dev/null
    ionline=`echo $?`
    ping -c 2 $j > /dev/null
    jonline=`echo $?`
     if [[ $ionline == 0 && $jonline == 0 ]]
      then
      mngb=`ssh -o "StrictHostKeyChecking no" $i iperf3 -f m -i 1 -c $j -t 10 2>/dev/null | grep receiver | awk -F ' ' '{print $7" "$8}'`
      echo -e "The bandwidth from $i to $j is $mngb" | tee -a /root/PycharmProjects/p_test/logs/$date.txt
	  echo -e "$mngb" | tee -a /root/PycharmProjects/p_test/logs/$date+.txt
     elif [[ $ionline == 1 && $jonline == 0 ]]
      then
      echo -e "$i is not online,skip....."
      continue
     elif [[ $ionline == 0 && $jonline == 1 ]]
      then
      echo -e "$j is not online,skip....."
      continue
     else
      echo -e "$i and $j are not online,skip....."
      continue
     fi
  fi
 done
done
}

iperf3-start
band
iperf3-stop
