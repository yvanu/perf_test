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



read-4k()
{
# start to test read iops of the cloud disk
# please replace the fio config file path as your enviroment
echo -e "\e[1mstart to test 4k read performence of the cloud disk.....\e[0m"
echo -e "the first time....."
IOPSR1=`fio --name=test --filename=$disk --direct=1 --time_based --group_reporting --numjobs=$numjobs --rw=randread --bs=4k --iodepth=$iodepth --runtime=$runtime --ioengine=libaio | grep iops | awk -F ', ' '{print $3}' | cut -d = -f 2`
THROUGHPUT1=`fio --name=test --filename=$disk --direct=1 --time_based --group_reporting --numjobs=$numjobs --rw=randread --bs=4k --iodepth=$iodepth --runtime=$runtime --ioengine=libaio  | grep bw= | awk -F ', ' '{print $2}' | cut -d = -f 2`
echo -e "first read 4k iops test result is $IOPSR1" | tee -a /root/PycharmProjects/p_test/logs/$date.txt
echo -e "$IOPSR1" | tee -a /root/PycharmProjects/p_test/logs/$date+.txt
echo -e "first read 4k throughput test result is $THROUGHPUT1" | tee -a /root/PycharmProjects/p_test/logs/$date.txt
echo -e "$THROUGHPUT1" | tee -a /root/PycharmProjects/p_test/logs/$date+.txt

echo -e "the second time....."
IOPSR2=`fio --name=test --filename=$disk --direct=1 --time_based --group_reporting --numjobs=$numjobs --rw=randread --bs=4k --iodepth=$iodepth --runtime=$runtime --ioengine=libaio  | grep iops | awk -F ', ' '{print $3}' | cut -d = -f 2`
THROUGHPUT2=`fio --name=test --filename=$disk --direct=1 --time_based --group_reporting --numjobs=$numjobs --rw=randread --bs=4k --iodepth=$iodepth --runtime=$runtime --ioengine=libaio  | grep bw= | awk -F ', ' '{print $2}' | cut -d = -f 2`
echo -e "second read 4k iops test result is $IOPSR2" | tee -a /root/PycharmProjects/p_test/logs/$date.txt
echo -e "$IOPSR2" | tee -a /root/PycharmProjects/p_test/logs/$date+.txt
echo -e "second read 4k throughput test result is $THROUGHPUT2" | tee -a /root/PycharmProjects/p_test/logs/$date.txt
echo -e "$THROUGHPUT2" | tee -a /root/PycharmProjects/p_test/logs/$date+.txt

echo -e "the third time....."
IOPSR3=`fio --name=test --filename=$disk --direct=1 --time_based --group_reporting --numjobs=$numjobs --rw=randread --bs=4k --iodepth=$iodepth --runtime=$runtime --ioengine=libaio  | grep iops | awk -F ', ' '{print $3}' | cut -d = -f 2`
THROUGHPUT3=`fio --name=test --filename=$disk --direct=1 --time_based --group_reporting --numjobs=$numjobs --rw=randread --bs=4k --iodepth=$iodepth --runtime=$runtime --ioengine=libaio  | grep bw= | awk -F ', ' '{print $2}' | cut -d = -f 2`
echo -e "the third read 4k iops test result is $IOPSR3"  | tee -a /root/PycharmProjects/p_test/logs/$date.txt
echo -e "$IOPSR3" | tee -a /root/PycharmProjects/p_test/logs/$date+.txt
echo -e "the third read 4k throughput test result is $THROUGHPUT3"  | tee -a /root/PycharmProjects/p_test/logs/$date.txt
echo -e "$THROUGHPUT3" | tee -a /root/PycharmProjects/p_test/logs/$date+.txt
echo -e "============================================================================"
}

write-4k()
{
# start to test write iops of the cloud disk
# please replace the fio config file path as your enviroment
echo -e "\e[1mstart to test 4k write performence of the cloud disk.....\e[0m" | tee -a /var/log/zs-perf-vm-$date.log
echo "the first time....."
IOPSW1=`fio --name=test --filename=$disk --direct=1 --time_based --group_reporting --numjobs=$numjobs --rw=randwrite --bs=4k --iodepth=$iodepth --runtime=$runtime --ioengine=libaio  | grep iops | awk -F ', ' '{print $3}' | cut -d = -f 2`
THROUGHPUT1=`fio --name=test --filename=$disk --direct=1 --time_based --group_reporting --numjobs=$numjobs --rw=randwrite --bs=4k --iodepth=$iodepth --runtime=$runtime --ioengine=libaio  | grep bw= | awk -F ', ' '{print $2}' | cut -d = -f 2`
echo -e "first write 4k iops test result is $IOPSW1"  | tee -a /root/PycharmProjects/p_test/logs/$date.txt
echo -e "$IOPSW1" | tee -a /root/PycharmProjects/p_test/logs/$date+.txt
echo -e "first write 4k throughput test result is $THROUGHPUT1"  | tee -a /root/PycharmProjects/p_test/logs/$date.txt
echo -e "$THROUGHPUT1" | tee -a /root/PycharmProjects/p_test/logs/$date+.txt
echo -e "the second time....."
IOPSW2=`fio --name=test --filename=$disk --direct=1 --time_based --group_reporting --numjobs=$numjobs --rw=randwrite --bs=4k --iodepth=$iodepth --runtime=$runtime --ioengine=libaio  | grep iops | awk -F ', ' '{print $3}' | cut -d = -f 2`
THROUGHPUT2=`fio --name=test --filename=$disk --direct=1 --time_based --group_reporting --numjobs=$numjobs --rw=randwrite --bs=4k --iodepth=$iodepth --runtime=$runtime --ioengine=libaio  | grep bw= | awk -F ', ' '{print $2}' | cut -d = -f 2`
echo -e "second write 4k iops test result is $IOPSW2"  | tee -a /root/PycharmProjects/p_test/logs/$date.txt
echo -e "$IOPSW2" | tee -a /root/PycharmProjects/p_test/logs/$date+.txt
echo -e "second write 4k throughput test result is $THROUGHPUT2"  | tee -a /root/PycharmProjects/p_test/logs/$date.txt
echo -e "$THROUGHPUT2" | tee -a /root/PycharmProjects/p_test/logs/$date+.txt
echo -e "the third time....."
IOPSW3=`fio --name=test --filename=$disk --direct=1 --time_based --group_reporting --numjobs=$numjobs --rw=randwrite --bs=4k --iodepth=$iodepth --runtime=$runtime --ioengine=libaio  | grep iops | awk -F ', ' '{print $3}' | cut -d = -f 2`
THROUGHPUT3=`fio --name=test --filename=$disk --direct=1 --time_based --group_reporting --numjobs=$numjobs --rw=randwrite --bs=4k --iodepth=$iodepth --runtime=$runtime --ioengine=libaio  | grep bw= | awk -F ', ' '{print $2}' | cut -d = -f 2`
echo -e "the third write 4k iops test result is $IOPSW3"  | tee -a /root/PycharmProjects/p_test/logs/$date.txt
echo -e "$IOPSW3" | tee -a /root/PycharmProjects/p_test/logs/$date+.txt
echo -e "the third write 4k throughput test result is $THROUGHPUT3"  | tee -a /root/PycharmProjects/p_test/logs/$date.txt
echo -e "$THROUGHPUT3" | tee -a /root/PycharmProjects/p_test/logs/$date+.txt
echo -e "============================================================================"
}

readwrite-4k()
{
# start to test read iops of the cloud disk
# please replace the fio config file path as your enviroment
echo -e "\e[1mstart to test 4k readwrite performence of the cloud disk.....\e[0m"
echo -e "the first time....."
IOPSREAD1=`fio --name=test --filename=$disk --direct=1 --time_based --group_reporting --numjobs=$numjobs --rw=readwrite --bs=4k --iodepth=$iodepth --runtime=$runtime --ioengine=libaio | grep read | head -n 1 | grep iops | awk -F ', ' '{print $3}' | cut -d = -f 2`
THROUGHPUTREAD1=`fio --name=test --filename=$disk --direct=1 --time_based --group_reporting --numjobs=$numjobs --rw=readwrite --bs=4k --iodepth=$iodepth --runtime=$runtime --ioengine=libaio  | grep read | head -n 1 | grep bw= | awk -F ', ' '{print $2}' | cut -d = -f 2`
IOPSWRITE1=`fio --name=test --filename=$disk --direct=1 --time_based --group_reporting --numjobs=$numjobs --rw=readwrite --bs=4k --iodepth=$iodepth --runtime=$runtime --ioengine=libaio | grep write | head -n 1 | grep iops | awk -F ', ' '{print $3}' | cut -d = -f 2`
THROUGHPUTWRITE1=`fio --name=test --filename=$disk --direct=1 --time_based --group_reporting --numjobs=$numjobs --rw=readwrite --bs=4k --iodepth=$iodepth --runtime=$runtime --ioengine=libaio  | grep write | head -n 1 | grep bw= | awk -F ', ' '{print $2}' | cut -d = -f 2`
echo -e "first readwrite 4k iops test result is read $IOPSREAD1,write $IOPSWRITE1"  | tee -a /root/PycharmProjects/p_test/logs/$date.txt
echo -e "$IOPSREAD1" | tee -a /root/PycharmProjects/p_test/logs/$date+.txt
echo -e "$IOPSWRITE1" | tee -a /root/PycharmProjects/p_test/logs/$date+.txt
echo -e "first readwrite 4k throughput test result is read $THROUGHPUTREAD1,write $THROUGHPUTWRITE1"  | tee -a /root/PycharmProjects/p_test/logs/$date.txt
echo -e "$THROUGHPUTREAD1" | tee -a /root/PycharmProjects/p_test/logs/$date+.txt
echo -e "$THROUGHPUTWRITE1" | tee -a /root/PycharmProjects/p_test/logs/$date+.txt
echo -e "the second time....."
IOPSREAD2=`fio --name=test --filename=$disk --direct=1 --time_based --group_reporting --numjobs=$numjobs --rw=readwrite --bs=4k --iodepth=$iodepth --runtime=$runtime --ioengine=libaio | grep read | head -n 1 | grep iops | awk -F ', ' '{print $3}' | cut -d = -f 2`
THROUGHPUTREAD2=`fio --name=test --filename=$disk --direct=1 --time_based --group_reporting --numjobs=$numjobs --rw=readwrite --bs=4k --iodepth=$iodepth --runtime=$runtime --ioengine=libaio  | grep read | head -n 1 | grep bw= | awk -F ', ' '{print $2}' | cut -d = -f 2`
IOPSWRITE2=`fio --name=test --filename=$disk --direct=1 --time_based --group_reporting --numjobs=$numjobs --rw=readwrite --bs=4k --iodepth=$iodepth --runtime=$runtime --ioengine=libaio | grep write | head -n 1 | grep iops | awk -F ', ' '{print $3}' | cut -d = -f 2`
THROUGHPUTWRITE2=`fio --name=test --filename=$disk --direct=1 --time_based --group_reporting --numjobs=$numjobs --rw=readwrite --bs=4k --iodepth=$iodepth --runtime=$runtime --ioengine=libaio  | grep write | head -n 1 | grep bw= | awk -F ', ' '{print $2}' | cut -d = -f 2`
echo -e "second readwrite 4k iops test result is read $IOPSREAD2,write $IOPSWRITE2" | tee -a /root/PycharmProjects/p_test/logs/$date.txt
echo -e "$IOPSREAD2" | tee -a /root/PycharmProjects/p_test/logs/$date+.txt
echo -e "$IOPSWRITE2" | tee -a /root/PycharmProjects/p_test/logs/$date+.txt
echo -e "second readwrite 4k throughput test result is read $THROUGHPUTREAD2,write $THROUGHPUTWRITE2" | tee -a /root/PycharmProjects/p_test/logs/$date.txt
echo -e "$THROUGHPUTREAD2" | tee -a /root/PycharmProjects/p_test/logs/$date+.txt
echo -e "$THROUGHPUTWRITE2" | tee -a /root/PycharmProjects/p_test/logs/$date+.txt
echo -e "the third time....."
IOPSREAD3=`fio --name=test --filename=$disk --direct=1 --time_based --group_reporting --numjobs=$numjobs --rw=readwrite --bs=4k --iodepth=$iodepth --runtime=$runtime --ioengine=libaio | grep read | head -n 1 | grep iops | awk -F ', ' '{print $3}' | cut -d = -f 2`
THROUGHPUTREAD3=`fio --name=test --filename=$disk --direct=1 --time_based --group_reporting --numjobs=$numjobs --rw=readwrite --bs=4k --iodepth=$iodepth --runtime=$runtime --ioengine=libaio  | grep read | head -n 1 | grep bw= | awk -F ', ' '{print $2}' | cut -d = -f 2`
IOPSWRITE3=`fio --name=test --filename=$disk --direct=1 --time_based --group_reporting --numjobs=$numjobs --rw=readwrite --bs=4k --iodepth=$iodepth --runtime=$runtime --ioengine=libaio | grep write | head -n 1 | grep iops | awk -F ', ' '{print $3}' | cut -d = -f 2`
THROUGHPUTWRITE3=`fio --name=test --filename=$disk --direct=1 --time_based --group_reporting --numjobs=$numjobs --rw=readwrite --bs=4k --iodepth=$iodepth --runtime=$runtime --ioengine=libaio  | grep write | head -n 1 | grep bw= | awk -F ', ' '{print $2}' | cut -d = -f 2`
echo -e "the third readwrite 4k iops test result is read $IOPSREAD3,write $IOPSWRITE3" | tee -a /root/PycharmProjects/p_test/logs/$date.txt
echo -e "$IOPSREAD3" | tee -a /root/PycharmProjects/p_test/logs/$date+.txt
echo -e "$IOPSWRITE3" | tee -a /root/PycharmProjects/p_test/logs/$date+.txt
echo -e "the third readwrite 4k throughput test result is read $THROUGHPUTREAD3,write $THROUGHPUTWRITE3" | tee -a /root/PycharmProjects/p_test/logs/$date.txt
echo -e "$THROUGHPUTREAD3" | tee -a /root/PycharmProjects/p_test/logs/$date+.txt
echo -e "$THROUGHPUTWRITE3" | tee -a /root/PycharmProjects/p_test/logs/$date+.txt
echo -e "============================================================================"
}

read-64k()
{
# start to test read iops of the cloud disk
# please replace the fio config file path as your enviroment
echo -e "\e[1mstart to test 64k read performence of the cloud disk.....\e[0m"
echo -e "the first time....."
IOPSR1=`fio --name=test --filename=$disk --direct=1 --time_based --group_reporting --numjobs=$numjobs --rw=randread --bs=64k --iodepth=$iodepth --runtime=$runtime --ioengine=libaio | grep iops | awk -F ', ' '{print $3}' | cut -d = -f 2`
THROUGHPUT1=`fio --name=test --filename=$disk --direct=1 --time_based --group_reporting --numjobs=$numjobs --rw=randread --bs=64k --iodepth=$iodepth --runtime=$runtime --ioengine=libaio  | grep bw= | awk -F ', ' '{print $2}' | cut -d = -f 2`
echo -e "first read 64k iops test result is $IOPSR1" | tee -a /root/PycharmProjects/p_test/logs/$date.txt
echo -e "first read 64k throughput test result is $THROUGHPUT1" | tee -a /root/PycharmProjects/p_test/logs/$date.txt
echo -e "$IOPSR1" | tee -a /root/PycharmProjects/p_test/logs/$date+.txt
echo -e "$THROUGHPUT1" | tee -a /root/PycharmProjects/p_test/logs/$date+.txt

echo -e "the second time....."
IOPSR2=`fio --name=test --filename=$disk --direct=1 --time_based --group_reporting --numjobs=$numjobs --rw=randread --bs=64k --iodepth=$iodepth --runtime=$runtime --ioengine=libaio  | grep iops | awk -F ', ' '{print $3}' | cut -d = -f 2`
THROUGHPUT2=`fio --name=test --filename=$disk --direct=1 --time_based --group_reporting --numjobs=$numjobs --rw=randread --bs=64k --iodepth=$iodepth --runtime=$runtime --ioengine=libaio  | grep bw= | awk -F ', ' '{print $2}' | cut -d = -f 2`
echo -e "second read 64k iops test result is $IOPSR2" | tee -a /root/PycharmProjects/p_test/logs/$date.txt
echo -e "second read 64k throughput test result is $THROUGHPUT2" | tee -a /root/PycharmProjects/p_test/logs/$date.txt
echo -e "$IOPSR2" | tee -a /root/PycharmProjects/p_test/logs/$date+.txt
echo -e "$THROUGHPUT2" | tee -a /root/PycharmProjects/p_test/logs/$date+.txt

echo -e "the third time....."
IOPSR3=`fio --name=test --filename=$disk --direct=1 --time_based --group_reporting --numjobs=$numjobs --rw=randread --bs=64k --iodepth=$iodepth --runtime=$runtime --ioengine=libaio  | grep iops | awk -F ', ' '{print $3}' | cut -d = -f 2`
THROUGHPUT3=`fio --name=test --filename=$disk --direct=1 --time_based --group_reporting --numjobs=$numjobs --rw=randread --bs=64k --iodepth=$iodepth --runtime=$runtime --ioengine=libaio  | grep bw= | awk -F ', ' '{print $2}' | cut -d = -f 2`
echo -e "the third read 64k iops test result is $IOPSR3"  | tee -a /root/PycharmProjects/p_test/logs/$date.txt
echo -e "the third read 64k throughput test result is $THROUGHPUT3"  | tee -a /root/PycharmProjects/p_test/logs/$date.txt
echo -e "$IOPSR3" | tee -a /root/PycharmProjects/p_test/logs/$date+.txt
echo -e "$THROUGHPUT3" | tee -a /root/PycharmProjects/p_test/logs/$date+.txt
echo -e "============================================================================"
}

write-64k()
{
# start to test write iops of the cloud disk
# please replace the fio config file path as your enviroment
echo -e "\e[1mstart to test 64k write performence of the cloud disk.....\e[0m" | tee -a /var/log/zs-perf-vm-$date.log
echo "the first time....."
IOPSW1=`fio --name=test --filename=$disk --direct=1 --time_based --group_reporting --numjobs=$numjobs --rw=randwrite --bs=64k --iodepth=$iodepth --runtime=$runtime --ioengine=libaio  | grep iops | awk -F ', ' '{print $3}' | cut -d = -f 2`
THROUGHPUT1=`fio --name=test --filename=$disk --direct=1 --time_based --group_reporting --numjobs=$numjobs --rw=randwrite --bs=64k --iodepth=$iodepth --runtime=$runtime --ioengine=libaio  | grep bw= | awk -F ', ' '{print $2}' | cut -d = -f 2`
echo -e "first write 64k iops test result is $IOPSW1"  | tee -a /root/PycharmProjects/p_test/logs/$date.txt
echo -e "first write 64k throughput test result is $THROUGHPUT1"  | tee -a /root/PycharmProjects/p_test/logs/$date.txt
echo -e "$IOPSW1" | tee -a /root/PycharmProjects/p_test/logs/$date+.txt
echo -e "$THROUGHPUT1" | tee -a /root/PycharmProjects/p_test/logs/$date+.txt

echo -e "the second time....."
IOPSW2=`fio --name=test --filename=$disk --direct=1 --time_based --group_reporting --numjobs=$numjobs --rw=randwrite --bs=64k --iodepth=$iodepth --runtime=$runtime --ioengine=libaio  | grep iops | awk -F ', ' '{print $3}' | cut -d = -f 2`
THROUGHPUT2=`fio --name=test --filename=$disk --direct=1 --time_based --group_reporting --numjobs=$numjobs --rw=randwrite --bs=64k --iodepth=$iodepth --runtime=$runtime --ioengine=libaio  | grep bw= | awk -F ', ' '{print $2}' | cut -d = -f 2`
echo -e "second write 64k iops test result is $IOPSW2"  | tee -a /root/PycharmProjects/p_test/logs/$date.txt
echo -e "second write 64k throughput test result is $THROUGHPUT2"  | tee -a /root/PycharmProjects/p_test/logs/$date.txt
echo -e "$IOPSW2" | tee -a /root/PycharmProjects/p_test/logs/$date+.txt
echo -e "$THROUGHPUT2" | tee -a /root/PycharmProjects/p_test/logs/$date+.txt

echo -e "the third time....."
IOPSW3=`fio --name=test --filename=$disk --direct=1 --time_based --group_reporting --numjobs=$numjobs --rw=randwrite --bs=64k --iodepth=$iodepth --runtime=$runtime --ioengine=libaio  | grep iops | awk -F ', ' '{print $3}' | cut -d = -f 2`
THROUGHPUT3=`fio --name=test --filename=$disk --direct=1 --time_based --group_reporting --numjobs=$numjobs --rw=randwrite --bs=64k --iodepth=$iodepth --runtime=$runtime --ioengine=libaio  | grep bw= | awk -F ', ' '{print $2}' | cut -d = -f 2`
echo -e "the third write 64k iops test result is $IOPSW3"  | tee -a /root/PycharmProjects/p_test/logs/$date.txt
echo -e "the third write 64k throughput test result is $THROUGHPUT3"  | tee -a /root/PycharmProjects/p_test/logs/$date.txt
echo -e "$IOPSW3" | tee -a /root/PycharmProjects/p_test/logs/$date+.txt
echo -e "$THROUGHPUT3" | tee -a /root/PycharmProjects/p_test/logs/$date+.txt
echo -e "============================================================================"
}

readwrite-64k()
{
# start to test read iops of the cloud disk
# please replace the fio config file path as your enviroment
echo -e "\e[1mstart to test 64k readwrite performence of the cloud disk.....\e[0m"
echo -e "the first time....."
IOPSREAD1=`fio --name=test --filename=$disk --direct=1 --time_based --group_reporting --numjobs=$numjobs --rw=readwrite --bs=64k --iodepth=$iodepth --runtime=$runtime --ioengine=libaio | grep read | head -n 1 | grep iops | awk -F ', ' '{print $3}' | cut -d = -f 2`
THROUGHPUTREAD1=`fio --name=test --filename=$disk --direct=1 --time_based --group_reporting --numjobs=$numjobs --rw=readwrite --bs=64k --iodepth=$iodepth --runtime=$runtime --ioengine=libaio  | grep read | head -n 1 | grep bw= | awk -F ', ' '{print $2}' | cut -d = -f 2`
IOPSWRITE1=`fio --name=test --filename=$disk --direct=1 --time_based --group_reporting --numjobs=$numjobs --rw=readwrite --bs=64k --iodepth=$iodepth --runtime=$runtime --ioengine=libaio | grep write | head -n 1 | grep iops | awk -F ', ' '{print $3}' | cut -d = -f 2`
THROUGHPUTWRITE1=`fio --name=test --filename=$disk --direct=1 --time_based --group_reporting --numjobs=$numjobs --rw=readwrite --bs=64k --iodepth=$iodepth --runtime=$runtime --ioengine=libaio  | grep write | head -n 1 | grep bw= | awk -F ', ' '{print $2}' | cut -d = -f 2`
echo -e "first readwrite 64k iops test result is read $IOPSREAD1,write $IOPSWRITE1"  | tee -a /root/PycharmProjects/p_test/logs/$date.txt
echo -e "first readwrite 64k throughput test result is read $THROUGHPUTREAD1,write $THROUGHPUTWRITE1"  | tee -a /root/PycharmProjects/p_test/logs/$date.txt
echo -e "$IOPSREAD1" | tee -a /root/PycharmProjects/p_test/logs/$date+.txt
echo -e "$IOPSWRITE1" | tee -a /root/PycharmProjects/p_test/logs/$date+.txt
echo -e "$THROUGHPUTREAD1" | tee -a /root/PycharmProjects/p_test/logs/$date+.txt
echo -e "$THROUGHPUTWRITE1" | tee -a /root/PycharmProjects/p_test/logs/$date+.txt

echo -e "the second time....."
IOPSREAD2=`fio --name=test --filename=$disk --direct=1 --time_based --group_reporting --numjobs=$numjobs --rw=readwrite --bs=64k --iodepth=$iodepth --runtime=$runtime --ioengine=libaio | grep read | head -n 1 | grep iops | awk -F ', ' '{print $3}' | cut -d = -f 2`
THROUGHPUTREAD2=`fio --name=test --filename=$disk --direct=1 --time_based --group_reporting --numjobs=$numjobs --rw=readwrite --bs=64k --iodepth=$iodepth --runtime=$runtime --ioengine=libaio  | grep read | head -n 1 | grep bw= | awk -F ', ' '{print $2}' | cut -d = -f 2`
IOPSWRITE2=`fio --name=test --filename=$disk --direct=1 --time_based --group_reporting --numjobs=$numjobs --rw=readwrite --bs=64k --iodepth=$iodepth --runtime=$runtime --ioengine=libaio | grep write | head -n 1 | grep iops | awk -F ', ' '{print $3}' | cut -d = -f 2`
THROUGHPUTWRITE2=`fio --name=test --filename=$disk --direct=1 --time_based --group_reporting --numjobs=$numjobs --rw=readwrite --bs=64k --iodepth=$iodepth --runtime=$runtime --ioengine=libaio  | grep write | head -n 1 | grep bw= | awk -F ', ' '{print $2}' | cut -d = -f 2`
echo -e "second readwrite 64k iops test result is read $IOPSREAD2,write $IOPSWRITE2" | tee -a /root/PycharmProjects/p_test/logs/$date.txt
echo -e "second readwrite 64k throughput test result is read $THROUGHPUTREAD2,write $THROUGHPUTWRITE2" | tee -a /root/PycharmProjects/p_test/logs/$date.txt
echo -e "$IOPSREAD2" | tee -a /root/PycharmProjects/p_test/logs/$date+.txt
echo -e "$IOPSWRITE2" | tee -a /root/PycharmProjects/p_test/logs/$date+.txt
echo -e "$THROUGHPUTREAD2" | tee -a /root/PycharmProjects/p_test/logs/$date+.txt
echo -e "$THROUGHPUTWRITE2" | tee -a /root/PycharmProjects/p_test/logs/$date+.txt

echo -e "the third time....."
IOPSREAD3=`fio --name=test --filename=$disk --direct=1 --time_based --group_reporting --numjobs=$numjobs --rw=readwrite --bs=64k --iodepth=$iodepth --runtime=$runtime --ioengine=libaio | grep read | head -n 1 | grep iops | awk -F ', ' '{print $3}' | cut -d = -f 2`
THROUGHPUTREAD3=`fio --name=test --filename=$disk --direct=1 --time_based --group_reporting --numjobs=$numjobs --rw=readwrite --bs=64k --iodepth=$iodepth --runtime=$runtime --ioengine=libaio  | grep read | head -n 1 | grep bw= | awk -F ', ' '{print $2}' | cut -d = -f 2`
IOPSWRITE3=`fio --name=test --filename=$disk --direct=1 --time_based --group_reporting --numjobs=$numjobs --rw=readwrite --bs=64k --iodepth=$iodepth --runtime=$runtime --ioengine=libaio | grep write | head -n 1 | grep iops | awk -F ', ' '{print $3}' | cut -d = -f 2`
THROUGHPUTWRITE3=`fio --name=test --filename=$disk --direct=1 --time_based --group_reporting --numjobs=$numjobs --rw=readwrite --bs=64k --iodepth=$iodepth --runtime=$runtime --ioengine=libaio  | grep write | head -n 1 | grep bw= | awk -F ', ' '{print $2}' | cut -d = -f 2`
echo -e "the third readwrite 64k iops test result is read $IOPSREAD3,write $IOPSWRITE3" | tee -a /root/PycharmProjects/p_test/logs/$date.txt
echo -e "the third readwrite 64k throughput test result is read $THROUGHPUTREAD3,write $THROUGHPUTWRITE3" | tee -a /root/PycharmProjects/p_test/logs/$date.txt
echo -e "$IOPSREAD3" | tee -a /root/PycharmProjects/p_test/logs/$date+.txt
echo -e "$IOPSWRITE3" | tee -a /root/PycharmProjects/p_test/logs/$date+.txt
echo -e "$THROUGHPUTREAD3" | tee -a /root/PycharmProjects/p_test/logs/$date+.txt
echo -e "$THROUGHPUTWRITE3" | tee -a /root/PycharmProjects/p_test/logs/$date+.txt
echo -e "============================================================================"
}


read-1m()
{
# start to test read iops of the cloud disk
# please replace the fio config file path as your enviroment
echo -e "\e[1mstart to test 1m read performence of the cloud disk.....\e[0m"
echo -e "the first time....."
IOPSR1=`fio --name=test --filename=$disk --direct=1 --time_based --group_reporting --numjobs=$numjobs --rw=randread --bs=1m --iodepth=$iodepth --runtime=$runtime --ioengine=libaio | grep iops | awk -F ', ' '{print $3}' | cut -d = -f 2`
THROUGHPUT1=`fio --name=test --filename=$disk --direct=1 --time_based --group_reporting --numjobs=$numjobs --rw=randread --bs=1m --iodepth=$iodepth --runtime=$runtime --ioengine=libaio  | grep bw= | awk -F ', ' '{print $2}' | cut -d = -f 2`
echo -e "first read 1m iops test result is $IOPSR1" | tee -a /root/PycharmProjects/p_test/logs/$date.txt
echo -e "$IOPSR1" | tee -a /root/PycharmProjects/p_test/logs/$date+.txt
echo -e "first read 1m throughput test result is $THROUGHPUT1" | tee -a /root/PycharmProjects/p_test/logs/$date.txt
echo -e "$THROUGHPUT1" | tee -a /root/PycharmProjects/p_test/logs/$date+.txt

echo -e "the second time....."
IOPSR2=`fio --name=test --filename=$disk --direct=1 --time_based --group_reporting --numjobs=$numjobs --rw=randread --bs=1m --iodepth=$iodepth --runtime=$runtime --ioengine=libaio  | grep iops | awk -F ', ' '{print $3}' | cut -d = -f 2`
THROUGHPUT2=`fio --name=test --filename=$disk --direct=1 --time_based --group_reporting --numjobs=$numjobs --rw=randread --bs=1m --iodepth=$iodepth --runtime=$runtime --ioengine=libaio  | grep bw= | awk -F ', ' '{print $2}' | cut -d = -f 2`
echo -e "second read 1m iops test result is $IOPSR2" | tee -a /root/PycharmProjects/p_test/logs/$date.txt
echo -e "$IOPSR2" | tee -a /root/PycharmProjects/p_test/logs/$date+.txt
echo -e "second read 1m throughput test result is $THROUGHPUT2" | tee -a /root/PycharmProjects/p_test/logs/$date.txt
echo -e "$THROUGHPUT2" | tee -a /root/PycharmProjects/p_test/logs/$date+.txt

echo -e "the third time....."
IOPSR3=`fio --name=test --filename=$disk --direct=1 --time_based --group_reporting --numjobs=$numjobs --rw=randread --bs=1m --iodepth=$iodepth --runtime=$runtime --ioengine=libaio  | grep iops | awk -F ', ' '{print $3}' | cut -d = -f 2`
THROUGHPUT3=`fio --name=test --filename=$disk --direct=1 --time_based --group_reporting --numjobs=$numjobs --rw=randread --bs=1m --iodepth=$iodepth --runtime=$runtime --ioengine=libaio  | grep bw= | awk -F ', ' '{print $2}' | cut -d = -f 2`
echo -e "the third read 1m iops test result is $IOPSR3"  | tee -a /root/PycharmProjects/p_test/logs/$date.txt
echo -e "$IOPSR3" | tee -a /root/PycharmProjects/p_test/logs/$date+.txt
echo -e "the third read 1m throughput test result is $THROUGHPUT3"  | tee -a /root/PycharmProjects/p_test/logs/$date.txt
echo -e "$THROUGHPUT3" | tee -a /root/PycharmProjects/p_test/logs/$date+.txt
echo -e "============================================================================"
}

write-1m()
{
# start to test write iops of the cloud disk
# please replace the fio config file path as your enviroment
echo -e "\e[1mstart to test 1m write performence of the cloud disk.....\e[0m" | tee -a /var/log/zs-perf-vm-$date.log
echo "the first time....."
IOPSW1=`fio --name=test --filename=$disk --direct=1 --time_based --group_reporting --numjobs=$numjobs --rw=randwrite --bs=1m --iodepth=$iodepth --runtime=$runtime --ioengine=libaio  | grep iops | awk -F ', ' '{print $3}' | cut -d = -f 2`
THROUGHPUT1=`fio --name=test --filename=$disk --direct=1 --time_based --group_reporting --numjobs=$numjobs --rw=randwrite --bs=1m --iodepth=$iodepth --runtime=$runtime --ioengine=libaio  | grep bw= | awk -F ', ' '{print $2}' | cut -d = -f 2`
echo -e "first write 1m iops test result is $IOPSW1"  | tee -a /root/PycharmProjects/p_test/logs/$date.txt
echo -e "$IOPSW1" | tee -a /root/PycharmProjects/p_test/logs/$date+.txt
echo -e "first write 1m throughput test result is $THROUGHPUT1"  | tee -a /root/PycharmProjects/p_test/logs/$date.txt
echo -e "$THROUGHPUT1" | tee -a /root/PycharmProjects/p_test/logs/$date+.txt

echo -e "the second time....."
IOPSW2=`fio --name=test --filename=$disk --direct=1 --time_based --group_reporting --numjobs=$numjobs --rw=randwrite --bs=1m --iodepth=$iodepth --runtime=$runtime --ioengine=libaio  | grep iops | awk -F ', ' '{print $3}' | cut -d = -f 2`
THROUGHPUT2=`fio --name=test --filename=$disk --direct=1 --time_based --group_reporting --numjobs=$numjobs --rw=randwrite --bs=1m --iodepth=$iodepth --runtime=$runtime --ioengine=libaio  | grep bw= | awk -F ', ' '{print $2}' | cut -d = -f 2`
echo -e "second write 1m iops test result is $IOPSW2"  | tee -a /root/PycharmProjects/p_test/logs/$date.txt
echo -e "$IOPSW2" | tee -a /root/PycharmProjects/p_test/logs/$date+.txt
echo -e "second write 1m throughput test result is $THROUGHPUT2"  | tee -a /root/PycharmProjects/p_test/logs/$date.txt
echo -e "$THROUGHPUT2" | tee -a /root/PycharmProjects/p_test/logs/$date+.txt

echo -e "the third time....."
IOPSW3=`fio --name=test --filename=$disk --direct=1 --time_based --group_reporting --numjobs=$numjobs --rw=randwrite --bs=1m --iodepth=$iodepth --runtime=$runtime --ioengine=libaio  | grep iops | awk -F ', ' '{print $3}' | cut -d = -f 2`
THROUGHPUT3=`fio --name=test --filename=$disk --direct=1 --time_based --group_reporting --numjobs=$numjobs --rw=randwrite --bs=1m --iodepth=$iodepth --runtime=$runtime --ioengine=libaio  | grep bw= | awk -F ', ' '{print $2}' | cut -d = -f 2`
echo -e "the third write 1m iops test result is $IOPSW3"  | tee -a /root/PycharmProjects/p_test/logs/$date.txt
echo -e "$IOPSW3" | tee -a /root/PycharmProjects/p_test/logs/$date+.txt
echo -e "the third write 1m throughput test result is $THROUGHPUT3"  | tee -a /root/PycharmProjects/p_test/logs/$date.txt
echo -e "$THROUGHPUT3" | tee -a /root/PycharmProjects/p_test/logs/$date+.txt
echo -e "============================================================================"
}

readwrite-1m()
{
# start to test read iops of the cloud disk
# please replace the fio config file path as your enviroment
echo -e "\e[1mstart to test 1m readwrite performence of the cloud disk.....\e[0m"
echo -e "the first time....."
IOPSREAD1=`fio --name=test --filename=$disk --direct=1 --time_based --group_reporting --numjobs=$numjobs --rw=readwrite --bs=1m --iodepth=$iodepth --runtime=$runtime --ioengine=libaio | grep read | head -n 1 | grep iops | awk -F ', ' '{print $3}' | cut -d = -f 2`
THROUGHPUTREAD1=`fio --name=test --filename=$disk --direct=1 --time_based --group_reporting --numjobs=$numjobs --rw=readwrite --bs=1m --iodepth=$iodepth --runtime=$runtime --ioengine=libaio  | grep read | head -n 1 | grep bw= | awk -F ', ' '{print $2}' | cut -d = -f 2`
IOPSWRITE1=`fio --name=test --filename=$disk --direct=1 --time_based --group_reporting --numjobs=$numjobs --rw=readwrite --bs=1m --iodepth=$iodepth --runtime=$runtime --ioengine=libaio | grep write | head -n 1 | grep iops | awk -F ', ' '{print $3}' | cut -d = -f 2`
THROUGHPUTWRITE1=`fio --name=test --filename=$disk --direct=1 --time_based --group_reporting --numjobs=$numjobs --rw=readwrite --bs=1m --iodepth=$iodepth --runtime=$runtime --ioengine=libaio  | grep write | head -n 1 | grep bw= | awk -F ', ' '{print $2}' | cut -d = -f 2`
echo -e "first readwrite 1m iops test result is read $IOPSREAD1,write $IOPSWRITE1"  | tee -a /root/PycharmProjects/p_test/logs/$date.txt
echo -e "first readwrite 1m throughput test result is read $THROUGHPUTREAD1,write $THROUGHPUTWRITE1"  | tee -a /root/PycharmProjects/p_test/logs/$date.txt
echo -e "$IOPSREAD1" | tee -a /root/PycharmProjects/p_test/logs/$date+.txt
echo -e "$IOPSWRITE1" | tee -a /root/PycharmProjects/p_test/logs/$date+.txt
echo -e "$THROUGHPUTREAD1" | tee -a /root/PycharmProjects/p_test/logs/$date+.txt
echo -e "$THROUGHPUTWRITE1" | tee -a /root/PycharmProjects/p_test/logs/$date+.txt

echo -e "the second time....."
IOPSREAD2=`fio --name=test --filename=$disk --direct=1 --time_based --group_reporting --numjobs=$numjobs --rw=readwrite --bs=1m --iodepth=$iodepth --runtime=$runtime --ioengine=libaio | grep read | head -n 1 | grep iops | awk -F ', ' '{print $3}' | cut -d = -f 2`
THROUGHPUTREAD2=`fio --name=test --filename=$disk --direct=1 --time_based --group_reporting --numjobs=$numjobs --rw=readwrite --bs=1m --iodepth=$iodepth --runtime=$runtime --ioengine=libaio  | grep read | head -n 1 | grep bw= | awk -F ', ' '{print $2}' | cut -d = -f 2`
IOPSWRITE2=`fio --name=test --filename=$disk --direct=1 --time_based --group_reporting --numjobs=$numjobs --rw=readwrite --bs=1m --iodepth=$iodepth --runtime=$runtime --ioengine=libaio | grep write | head -n 1 | grep iops | awk -F ', ' '{print $3}' | cut -d = -f 2`
THROUGHPUTWRITE2=`fio --name=test --filename=$disk --direct=1 --time_based --group_reporting --numjobs=$numjobs --rw=readwrite --bs=1m --iodepth=$iodepth --runtime=$runtime --ioengine=libaio  | grep write | head -n 1 | grep bw= | awk -F ', ' '{print $2}' | cut -d = -f 2`
echo -e "second readwrite 1m iops test result is read $IOPSREAD2,write $IOPSWRITE2" | tee -a /root/PycharmProjects/p_test/logs/$date.txt
echo -e "second readwrite 1m throughput test result is read $THROUGHPUTREAD2,write $THROUGHPUTWRITE2" | tee -a /root/PycharmProjects/p_test/logs/$date.txt
echo -e "$IOPSREAD2" | tee -a /root/PycharmProjects/p_test/logs/$date+.txt
echo -e "$IOPSWRITE2" | tee -a /root/PycharmProjects/p_test/logs/$date+.txt
echo -e "$THROUGHPUTREAD2" | tee -a /root/PycharmProjects/p_test/logs/$date+.txt
echo -e "$THROUGHPUTWRITE2" | tee -a /root/PycharmProjects/p_test/logs/$date+.txt

echo -e "the third time....."
IOPSREAD3=`fio --name=test --filename=$disk --direct=1 --time_based --group_reporting --numjobs=$numjobs --rw=readwrite --bs=1m --iodepth=$iodepth --runtime=$runtime --ioengine=libaio | grep read | head -n 1 | grep iops | awk -F ', ' '{print $3}' | cut -d = -f 2`
THROUGHPUTREAD3=`fio --name=test --filename=$disk --direct=1 --time_based --group_reporting --numjobs=$numjobs --rw=readwrite --bs=1m --iodepth=$iodepth --runtime=$runtime --ioengine=libaio  | grep read | head -n 1 | grep bw= | awk -F ', ' '{print $2}' | cut -d = -f 2`
IOPSWRITE3=`fio --name=test --filename=$disk --direct=1 --time_based --group_reporting --numjobs=$numjobs --rw=readwrite --bs=1m --iodepth=$iodepth --runtime=$runtime --ioengine=libaio | grep write | head -n 1 | grep iops | awk -F ', ' '{print $3}' | cut -d = -f 2`
THROUGHPUTWRITE3=`fio --name=test --filename=$disk --direct=1 --time_based --group_reporting --numjobs=$numjobs --rw=readwrite --bs=1m --iodepth=$iodepth --runtime=$runtime --ioengine=libaio  | grep write | head -n 1 | grep bw= | awk -F ', ' '{print $2}' | cut -d = -f 2`
echo -e "the third readwrite 1m iops test result is read $IOPSREAD3,write $IOPSWRITE3" | tee -a /root/PycharmProjects/p_test/logs/$date.txt
echo -e "the third readwrite 1m throughput test result is read $THROUGHPUTREAD3,write $THROUGHPUTWRITE3" | tee -a /root/PycharmProjects/p_test/logs/$date.txt
echo -e "$IOPSREAD3" | tee -a /root/PycharmProjects/p_test/logs/$date+.txt
echo -e "$IOPSWRITE3" | tee -a /root/PycharmProjects/p_test/logs/$date+.txt
echo -e "$THROUGHPUTREAD3" | tee -a /root/PycharmProjects/p_test/logs/$date+.txt
echo -e "$THROUGHPUTWRITE3" | tee -a /root/PycharmProjects/p_test/logs/$date+.txt
echo -e "============================================================================"
}

iperf3-start
band
iperf3-stop
read-4k
write-4k
readwrite-4k
read-64k
write-64k
readwrite-64k
read-1m
write-1m
readwrite-1m
