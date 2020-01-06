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


readwrite-64k
