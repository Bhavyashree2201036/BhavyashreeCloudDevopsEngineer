##########################################################
#Script name              : File_creation_alert
#Author's name            : Bhavyashree.R
#Objective of the script  : To display file names that is created at current time 
#Version of the script    : 0.0
#Date of creation         : 30-08-2025
#Date of modification     : 1-09-2025
##########################################################

#!/bin/bash
value=$(ls -lath | grep -i "Aug" | awk '{print $6}' | wc -l)
date_value=($(ls -lath | grep -i "Aug" | awk '{print $7}'))
time_value=($(ls -lath | grep -i "Aug" | awk '{print $8}'))
file_name=($(ls -lath | grep -i "Aug" | awk '{print $9}'))
month=$(date +%b)
today=$(date +%d)
time=$(date +%H:%M)
for (( i=0; i<value; i++ )); do
    if [[ "${date_value[i]}" == "$today" ]]; then
        if [[ "$month" == "Aug" ]]; then
		if [[ "${time_value[i]}" == "$time" ]]; then
                        #echo "${date_value[i]}"
			  echo "file_name : ${file_name[i]}"
			fi
	                     fi
                                   fi
                                    done
