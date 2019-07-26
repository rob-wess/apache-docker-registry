#!/bin/bash


# Formatting variables
	damon=$(systemctl list-unit-files | grep enabled | head -n 1 | awk '{print $1}')
	dot=$(systemctl status $damon | head -n 1  | cut -d " " -f 1)
	wid=$(tput cols)
	total=$(( $wid - 23 ))
	SUCCESS=$(tput setaf 2; tput bold; echo "SUCCESS")
	FAIL=$(tput setaf 1; tput bold; echo "FAIL")
	fail_log=/tmp/fail_log.txt


function Print-Message () 
	{
		 str=$1
		 num=$2
		 v=$(printf "%-${num}s" "$str")
		 echo -e "\t$3 $4 ${v// /.} $5"
	}

function Check-Host ()
	{
		tput bold; echo -e \\n"Check Host Requirements"\\n; tput sgr0
		
		# Check 1
		message="Check ansible is installed"
		len=$(echo $message | wc -c)
		difference=$(( $total - $len - 7 ))
		if [ ! -f /bin/ansible/ ]; then
			Print-Message " " $difference $dot "$message" "$SUCCESS" && tput sgr0
		else
			Print-Message " " $difference $dot "$message" "$FAIL" && tput sgr0
			echo -e "\tCHECK: $message" >> $fail_log
			echo -e "\t\tRESULT: Could not find the file /bin/ansible. Is it somewhere else?"\\n >> $fail_log
		fi
		
		# Check 2
		message="Check docker is installed"
		len=$(echo $message | wc -c)
		difference=$(( $total - $len - 7 ))
		if [ ! -f /bin/docker/ ]; then
			Print-Message " " $difference $dot "$message" "$SUCCESS" && tput sgr0
		else
			Print-Message " " $difference $dot "$message" "$FAIL" && tput sgr0
			echo -e "\tCHECK: $message" >> $fail_log
			echo -e "\t\tRESULT: Could not find the file /bin/docker. Is it somewhere else?"\\n >> $fail_log
		fi
		
		# Check 3
		message="Check docker-compose is installed"
		len=$(echo $message | wc -c)
		difference=$(( $total - $len - 7 ))
		if [ -f /usr/local/bin/docker-compose ]; then
			Print-Message " " $difference $dot "$message" "$SUCCESS" && tput sgr0
		else
			Print-Message " " $difference $dot "$message" "$FAIL" && tput sgr0
			echo -e "\tCHECK: $message" >> $fail_log
			echo -e "\t\tRESULT: Could not find the file /usr/local/bin/docker-compose. Is it somewhere else?"\\n >> $fail_log
		fi
	}

## 1. Run the openssl script
function Call-Openssl ()
	{
		
		sudo /home/ansible/registry-maker/scripts/create_certs.sh
	}


##2. Run the ansible plays
function Ansible-Plays ()
	{
		ansible-playbook /home/ansible/registry-maker/registry-maker.yml -i /home/ansible/registry-maker/hosts -b -K
	}
	
## 3. Run the docker/apache setup script
function Container-Setup ()
	{
		/home/docker/docker-registry/docker-setup.sh
	}
##4. Run the docker-compose script
function Docker-Compose ()
	{
		cd /home/docker/docker-registry &&  /usr/local/bin/docker-compose up
	}
function Fail-Exit ()
	{
		tput bold; tput setaf 1; tput smul; 
		echo -e \\n\\n"Failed Checks (output from $fail_log)"
		tput sgr0; 
		echo -e "\t$(cat $fail_log)"\\n\\n
	}

# Clear the log file
echo > $fail_log

#Run the Check-Host function and exit if any fails
Check-Host 
tput bold; tput setaf 2; tput smul
echo -e \\n"ALL CHECKS HAVE PASSED"
tput sgr0
echo -e \\n"The system is ready for installation and deployment of the secured registry container."\\n
tput sgr0
read -p "Press enter to continue or Ctrl+c to exit"

#Sudo up
sudo bash

# Call the openssl function 
Call-Openssl
# Call the Ansible-Plays function
Ansible-Plays

# Call the Container-Setup function
Container-Setup

# Call the Docker-Compose function
Docker-Compose

