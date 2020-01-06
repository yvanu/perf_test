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


read-1m
