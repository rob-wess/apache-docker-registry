#!/bin/bash

dockerDir=/home/docker/docker-registry

if [ ! -d $dockerDir ]; then
        mkdir -p $dockerDir
fi

rm -fv $dockerDir/*.{key,crt,csr,cer}

openssl genrsa -out $dockerDir/devdockerCA.key 2048
openssl req -x509 -new -nodes -key $dockerDir/devdockerCA.key -days 10000 -subj "$subj" -out $dockerDir/devdockerCA.crt
openssl genrsa -out $dockerDir/domain.key 2048
openssl req -subj $subj -new -key $dockerDir/domain.key -out $dockerDir/dev-docker-registry.com.csr
openssl x509 -req -in $dockerDir/dev-docker-registry.com.csr -CA $dockerDir/devdockerCA.crt -CAkey $dockerDir/devdockerCA.key -CAcreateserial -out $dockerDir/domain.crt -days 10000
