# apache-docker-registry

The ansible plays will load and configure a docker registry container (using registry:2 from docker.io). An apache container will also be configured using the latest httpd image as a front end to handle basic authentication and TLS/SSL. 

This repo is designed to be used on an offline system. The repo contains all of the images/packages needed. (Some might be missing but working to add them now).

- Pre-Reqs
  - An ansible user has been created and ssh keys generated/copied to the localhost 
  - The main script checks that ansible is installed, but doesn't check for version. The plays require 2.8 or greater. Either remove ansible completely and let the script install the right version, or manually install it first.

- Instructions 
  - Clone the repo and scp/rsync to the system to run it on. (Designed to run in air-gapped environment but will work on connected system)
  - Switch user to the ansible user (from the pre-reqs section) and cd in the repo (cd apache-docker-registry/)
  - Run the command `scripts/installer_main.sh` to kick off the installation.
  - Answer the questions and wait for the install to finish
  - After installation, switch user to 'docker' and cd into /home/docker/docker-registry/. (May need to change permissions on the directory)
  - Run 'docker-compose up' to start containers. Add -d option to start them detached.
  - Run 'docker login $registry_fqdn:5043' to test. 
  
  - Known Issues:
    - Authentication error when docker login is ran (see needed_changes.txt for more info)
    - docker-compose.yml uses the loopback address for the apache container. This can be changed to your public/internal IP
