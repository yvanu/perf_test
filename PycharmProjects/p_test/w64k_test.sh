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


write-64k
