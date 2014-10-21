# Docker for TYPO3 Neos

## Overview
This docker provides a simple Installation for a fresh TYPO3 Neos instance. This docker installs a fresh new 
TYPO3 Neos 1.1.2 instance and imports the Demo Package.


## Installation
Right now the setup is really basic. All you need is a container to wrap your database and run this TYPO3 Neos docker
with that databse container linked. Therefore start a MySQL-container with this command:

`docker run --name neos-mysql -e MYSQL_ROOT_PASSWORD=YOUR_PASSWORD -d mysql`

Make sure to change your database password.

To run the TYPO3 Neos docker run this command:

`docker run --name neos -d -p 8080:80 --link neos-mysql:db johannessteu/typo3neos`

Now give docker 1-2 min to set everything up. Your Installation is available by <your-servers-domain>:8080 .
If the port 8080 is already taken by another application you can change that easily e.g. to 8081 in the run command by using 
-p 8081:80. You can watch the installation process ty taking a look to the logs via "docker logs -f neos"

To login to the backend open <your-servers-domain>:8080/neos.
User: admin
Password: password

## Upcoming
- Make db-container more configurable
- Provide an data-container
- Choose the Context Neos should run in (Development / Production / Testing)
- Provide credentials for a new backend-user
- Kickstart a new Site by default
- Install additional plugins/packages via composer
