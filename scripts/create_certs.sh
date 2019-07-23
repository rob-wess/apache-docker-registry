#!/bin/bash

dockerDir=/home/docker/docker-registry

if [ ! -d $dockerDir ]; then
	mkdir -p $dockerDir
fi

rm -fv $dockerDir/*.{key,crt,csr,cer}


echo "Step 1"
openssl genrsa -out $dockerDir/devdockerCA.key 2048 && clear

echo "Step 2"
openssl req -x509 -new -nodes -key $dockerDir/devdockerCA.key -days 10000 -out $dockerDir/devdockerCA.crt  && clear

echo "Step 3"
openssl genrsa -out $dockerDir/domain.key 2048 && clear

echo "Step 4"
openssl req -new -key $dockerDir/domain.key -out $dockerDir/dev-docker-registry.com.csr && clear

echo "Step 5"
openssl x509 -req -in $dockerDir/dev-docker-registry.com.csr -CA $dockerDir/devdockerCA.crt -CAkey $dockerDir/devdockerCA.key -CAcreateserial -out $dockerDir/domain.crt -days 10000 
exit
