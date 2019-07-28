#!/bin/bash

clear
echo -e \\n
read -sp "Please enter the ansible user password:  " PASSWORD
echo -e \\n
export PASSWORD=$PASSWORD

sudo echo ""


# Formatting variables
	export damon=$(systemctl list-unit-files | grep enabled | head -n 1 | awk '{print $1}')
	export dot=$(systemctl status $damon | head -n 1  | cut -d " " -f 1)
	export wid=$(tput cols)
	export total=$(( $wid - 23 ))
	export SUCCESS=$(tput setaf 2; tput bold; echo "SUCCESS")
	export FAIL=$(tput setaf 1; tput bold; echo "FAIL")

# General Variables
	export fail_log=/tmp/fail_log.txt
	export script_dir=`pwd`



function Print-Message () 
	{
		 str=$1
		 num=$2
		 v=$(printf "%-${num}s" "$str")
		 echo -e "\t$3 $4 ${v// /.} $5"
	}
export -f Print-Message

function Check-Host ()
	{
		tput bold; echo -e \\n"Check Host Requirements"\\n; tput sgr0
		
		# Check 1
		message="Check ansible is installed"
		len=$(echo $message | wc -c)
		difference=$(( $total - $len - 7 ))
		if [ -f /bin/ansible/ ]; then
			export ansible_installed="1"
			Print-Message " " $difference $dot "$message" "$SUCCESS" && tput sgr0
		else
			export ansible_installed="0"
			Print-Message " " $difference $dot "$message" "$FAIL" && tput sgr0
			echo -e "\tCHECK: $message" >> $fail_log
			echo -e "\t\tRESULT: Could not find the file /bin/ansible. Is it somewhere else?"\\n >> $fail_log
		fi
		
		# Check 2
		message="Check docker is installed"
		len=$(echo $message | wc -c)
		difference=$(( $total - $len - 7 ))
		if [ -f /bin/docker/ ]; then
			export docker_installed="1"
			Print-Message " " $difference $dot "$message" "$SUCCESS" && tput sgr0
		else
			export docker_installed="0"
			Print-Message " " $difference $dot "$message" "$FAIL" && tput sgr0
			echo -e "\tCHECK: $message" >> $fail_log
			echo -e "\t\tRESULT: Could not find the file /bin/docker. Is it somewhere else?"\\n >> $fail_log
		fi
		
		# Check 3
		message="Check docker-compose is installed"
		len=$(echo $message | wc -c)
		difference=$(( $total - $len - 7 ))
		if [ ! -f /usr/local/bin/docker-compose ]; then
			export docker_compose_installed="1"
			Print-Message " " $difference $dot "$message" "$SUCCESS" && tput sgr0
		else
			export docker_compose_installed="0"
			Print-Message " " $difference $dot "$message" "$FAIL" && tput sgr0
			echo -e "\tCHECK: $message" >> $fail_log
			echo -e "\t\tRESULT: Could not find the file /usr/local/bin/docker-compose. Is it somewhere else?"\\n >> $fail_log
		fi

	if [[ "$ansible_installed" == "1" && "$docker_installed" == "1" && "$docker_compose_installed" == "1" ]]; then
		export host_status="prepped"
	else
		export host_status="unprepped"
	fi
	
	}
	
function Unpack-Tars ()
	{
		tput bold; echo -e \\n"Untar Needed Files"\\n; tput sgr0
		
		message="Untar install_docker_ce role"
		len=$(echo $message | wc -c)
		difference=$(( $total - $len - 7 ))

		if (tar -xzvf $PWD/install_docker_ce.tar.gz &> /dev/null); then
			Print-Message " " $difference $dot "$message" "$SUCCESS" && tput sgr0
		else
			Print-Message " " $difference $dot "$message" "$FAIL" && tput sgr0
			echo -e "\tCHECK: $message" >> $fail_log
			echo -e "\t\tRESULT: Could not untar install_docker_ce.tar.gz"\\n >> $fail_log
		fi

		
		message="Untar deploy_secure_registry role"
		len=$(echo $message | wc -c)
		difference=$(( $total - $len - 7 ))
			
		if (tar -xzvf $PWD/deploy_secure_registry.tar.gz &> /dev/null); then
			Print-Message " " $difference $dot "$message" "$SUCCESS" && tput sgr0
		else
			Print-Message " " $difference $dot "$message" "$FAIL" && tput sgr0
			echo -e "\tCHECK: $message" >> $fail_log
			echo -e "\t\tRESULT: Could not untar deploy_secure_registry.tar.gz"\\n >> $fail_log
		fi
	}

## 1. Run the openssl script
function Call-Openssl ()
	{
		
		sudo -S $PASSWORD /home/ansible/registry-maker/scripts/create_certs.sh
	}


##2. Run the ansible plays
function Ansible-Plays ()
	{
		tput bold; echo -e \\n"Untar Needed Files"\\n; tput sgr0
		tags=(create_install_directory copy_installers install_docker-ce start_docker_daemon create_docker_user update_user_paths)

		for tag in "${tags[@]}"; do
			message="Untar deploy_secure_registry role"
			len=$(echo $message | wc -c)
			difference=$(( $total - $len - 7 ))
			
			ansible-playbook $script_dir/install_docker.yml -i $script_dir/install_inventory.ini -b --extra-vars '$PASSWORD' --tags $tag
		done
	


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

#Unpack tar files
Unpack-Tars

#Run the Check-Host function and exit if any fails
Check-Host 
if [[ "$host_status" == "prepped" ]]; then
	tput bold; tput setaf 2; tput smul
	echo -e \\n"ALL CHECKS HAVE PASSED"
	tput sgr0
	echo -e \\n"The system is ready for installation and deployment of the secured registry container."\\n
	tput sgr0
	read -p "Press enter to continue or Ctrl+c to exit"
else
	tput bold; tput setaf 1; tput smul
	echo -e \\n"Host does not have all pre-reqs installed"
	tput sgr0
	echo -e \\n"The system is not ready for installation or deployment of the secured registry container."\\n
	tput sgr0
	echo -e \\n"We'll call the installer scripts now"\\n
	read -p "Press enter to continue or Ctrl+c to exit"
	
		scripts/install_prereqs.sh
	
fi


# Call the Ansible-Plays function
Ansible-Plays
exit

# Call the openssl function 
Call-Openssl

# Call the Container-Setup function
Container-Setup

# Call the Docker-Compose function
Docker-Compose

