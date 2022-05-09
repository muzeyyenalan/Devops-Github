#!/bin/bash

# default value to use if none specified
PERCENT=30

# test for command line arguement is present
if [[ $# -le 0 ]]
then
    printf "Using default value for threshold!\n"
# test if argument is an integer
# if it is, use that as percent, if not use default
else
    if [[ $1 =~ ^-?[0-9]+([0-9]+)?$ ]]
    then
        PERCENT=$1
    fi
fi

let "PERCENT += 0"
printf "Threshold = %d\n" $PERCENT

df -Ph | grep -vE '^Filesystem|tmpfs|cdrom' | awk '{ print $5,$1 }' | while read data;
do
    used=$(echo $data | awk '{print $1}' | sed s/%//g)
    p=$(echo $data | awk '{print $2}')
    if [ $used -ge $PERCENT ]
    then
        echo "WARNING: The partition \"$p\" has used $used% of total available space - Date: $(date)"
    fi
done



# The sed s/%//g command is used for omitting the percent sign from the output of df -Ph.
# df is the command to report file system disk space usage, while the options -Ph specify POSIX output and human-readable, meaning, print sizes in powers of 1024.
# awk(1) is used for extracting the desired fields from output of the df(1) command.
