#!/bin/bash

dockerDir=/home/docker/docker-registry

echo $subj
exit



if [ ! -d $dockerDir ]; then
	mkdir -p $dockerDir
fi

rm -fv $dockerDir/*.{key,crt,csr,cer}


echo "Step 1"
echo "openssl genrsa -out $dockerDir/devdockerCA.key 2048" # && clear

echo "Step 2"
echo "openssl req -x509 -new -nodes -key $dockerDir/devdockerCA.key -days 10000 -subj=$subj -out $dockerDir/devdockerCA.crt" # && clear

echo "Step 3"
echo "openssl genrsa -out $dockerDir/domain.key 2048" #&& clear

echo "Step 4"
echo "openssl req -subj=$subj -new -key $dockerDir/domain.key -out $dockerDir/dev-docker-registry.com.csr" # && clear

echo "Step 5"
echo "openssl x509 -req -in $dockerDir/dev-docker-registry.com.csr -CA $dockerDir/devdockerCA.crt -CAkey $dockerDir/devdockerCA.key -CAcreateserial -out $dockerDir/domain.crt -days 10000"
exit
