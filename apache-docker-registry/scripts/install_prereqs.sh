#!/bin/bash


tput bold; echo -e \\n"Install Pre-requisites"\\n; tput sgr0

# Check 1
message="Install ansible via rpm"
len=$(echo $message | wc -c)
difference=$(( $total - $len - 7 ))

if (sudo rpm -ivh  $PWD/deploy_secure_registry/files/ansible-2.8.1-1.el7.noarch.rpm &> /dev/null); then
	Print-Message " " $difference $dot "$message" "$SUCCESS" && tput sgr0; echo -e \\n
else
	Print-Message " " $difference $dot "$message" "$FAIL" && tput sgr0; echo -e \\n
	echo -e "\tCHECK: $message" >> $fail_log
	echo -e "\t\tRESULT: Ansible install failed. "\\n >> $fail_log
	echo -e "\t\tCMD: sudo rpm -ivh  $PWD/deploy_secure_registry/files/ansible-2.8.1-1.el7.noarch.rpm"\\n >> $fail_log
fi




