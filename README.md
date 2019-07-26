# apache-docker-registry
NOT YET READY FOR USE


The ansible plays will load and configure a docker registry container (using registry:2 from docker.io). An apache container will also be configured using the latest httpd image as a front end to handle basic authentication and TLS/SSL. 

This repo is designed to be used on an offline system. The repo contains all of the images/packages needed. (Some are might be missing but working to add them now).

Pre-Reqs
- An ansible user has been created and ssh keys generated/copied to the localhost or remote machine. 
