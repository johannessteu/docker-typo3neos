# Docker for TYPO3 Neos

## Overview
This docker provides a simple, fresh and almost fully customizable installation for TYPO3 Neos.
By default a TYPO3 Neos instance with the Demo Package is installed. You can even choose in which version you want to use it (e.g. 1.1.2 or current master).

*When should i use this docker?*
There are many scenarios why to use this docker. At first you will be able to run a fresh installation in just some minutes with no
need of any TYPO3 Neos knowledge. Docker will install everything for you. You can also choose between some options to configure Neos.
Are you an developer? Test your package in any Version with just one command! Simply provide the PACKAGES - option and 
see how your package works in the current master.

So if you are a developer or you just want to have some fun with TYPO3 Neos feel free to try this docker out.
For support or any type of help send me a tweet to [@stolle_](https://twitter.com/stolle_) or an [E-Mail](js@johannessteu.de)

## Installation
Right now the setup is really basic. All you need is a container to wrap your database and run this TYPO3 Neos docker
with that databse container linked. Therefore start a MySQL-container with this command:

`docker run --name neos-mysql -e MYSQL_ROOT_PASSWORD=YOUR_PASSWORD -d mysql`

Make sure to change your database password to your needs.

To run the TYPO3 Neos docker itself run this command:

`docker run --name neos -d -p 8080:80 --link neos-mysql:db johannessteu/typo3neos`

Now give docker 1-2 min to set everything up. Your Installation will be available under <your-servers-domain>:8080 .
If the port 8080 is already taken by another application just change it to e.g. 8081 in the run command by using 
-p 8081:80. You can watch the installation process ty taking a look into the logs via "docker logs -f neos"

To login to the backend open <your-servers-domain>:8080/neos .
User: admin
Password: password

If you want to change your login credentials have a look at the options section!


## Options
There are several options available to configure your TYPO3 Neos installation.

### Version
TYPO3 Neos will be installed per default in the current stable version (1.1.2). If you would rather like to work on the current master
to check out all new stuff you can provide the EnvVar VERSION. VERSION can be any branch, tag or commit on the [TYPO3.Neos git-repository](https://git.typo3.org/Neos/Distributions/Base.git).

So if you would like to test TYPO3 Neos 1.2 beta run this command:

`docker run --name neos -d -p 8080:80 --link neos-mysql:db -e VERSION=1.2 johannessteu/typo3neos`

### Context
TYPO3 Neos can run in three different contexts: Production (which is the default), Development and Testing. You can Start
TYPO3 Neos by providing the EnvVar CONTEXT. To run Neos in Development Mode run this docker with:

`docker run --name neos -d -p 8080:80 --link neos-mysql:db -e CONTEXT=Development johannessteu/typo3neos`

### Composer Requirements
You are able to add composer custom requirements to your new Neos installation. Your package hast to be available by the composer require command. Therefor it has to be public at the moment.
If your package is listed at [packagist.org](http://packagist.org) you are good to go. For the future it is planned to be able to
require also private Repositories. To require a Package pass the EnvVar PACKAGES. So if you would like to use a [flexible grid system that is based on bootstrap](https://github.com/jSteu/JohannesSteu.Bootstrap.GridSystem) 
run

`docker run --name neos -d -p 8080:80 --link neos-mysql:db -e PACKAGES=johannessteu/bootstrap-gridsystem`

Multiple Packages are seperated by a semicolon (;)


### Additional vars

| Name | Description          |
| ------------- | ----------- |
| DATABSE_NAME      | Set a name for the database to use. Defaults to neos |
| NEOS_USER     | Set the login name. Defaults to admin |
| NEOS_PASSWORD     | Set the password for NEOS_USER. Defaults to password |
| NEOS_FIRSTNAME     | Set the firstname for NEOS_USER. Defaults to John |
| NEOS_LASTNAME     | Set the lastname for NEOS_USER. Defaults to Doe |


## Known Bugs
- In Testing mode the dev-requirements are not installed. For now you could require those manually

## Upcoming
- Make db-container more configurable
- Put all Data optional in a data-container
- Kickstart a new Site if wanted
- Run the setup only once
- Provide an custom composer.json