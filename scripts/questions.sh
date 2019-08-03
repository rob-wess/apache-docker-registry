#!/bin/bash


echo "Enter ansible user's sudo password. NOTE: the will be place in plaintext in install_docker.yml"
read -sp "Enter Password:  " SUDO_PASSWORD
echo -e \\n

sed -i "s(SUDO_PASSWORD("$SUDO_PASSWORD"(g" $script_dir/install_docker.yml
sed -i "s(SUDO_PASSWORD("$SUDO_PASSWORD"(g" $script_dir/deploy_secure_registry.yml


echo "Enter the IP address you want to access your registry at"
read -p "Enter IP address:  " REGISTRY_IP
echo -e \\n
sed -i "s(REGISTRY_IP("$REGISTRY_IP"(g" $script_dir/deploy_secure_registry.yml


echo "Enter the fqdn of your reigstry server (can be something like localhost.local. This will be placed in the local hostfile"
read -p "Enter the FQDN of your registry:  " REGISTRY_FQDN
echo -e \\n
sed -i "s(REGISTRY_FQDN("$REGISTRY_FQDN"(g" $script_dir/deploy_secure_registry.yml



echo -e "Now we need some infromation for the self-signed certs. Please answer each prompt"

read -p "Country Name (2 letter code) [XX]:  " COUNTRY
read -p "State or Province Name (full name) []:  " STATE
read -p "Locality Name (eg, city) [Default City]:  " CITY
read -p "Organization Name (eg, company) [Default Company Ltd]:  " ORGANIZATION
read -p "Organizational Unit Name (eg, section) []:  " UNIT
read -p "Common Name (eg, your name or your server's hostname) []:  " COMMON_NAME
#read -p "Email Address []:  " EMAIL


subj="/C=$COUNTRY/ST=$STATE/L=$CITY/O=$ORGANIZATION/OU=$UNIT/CN=$COMMON_NAME"

