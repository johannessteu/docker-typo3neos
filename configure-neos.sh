#!/bin/sh

echo "*** Start setup Neos"

cd /var/www/neos

# Default vars
[ -z ${DATABASE_NAME} ] && DATABASE_NAME=neos
[ -z ${NEOS_USER} ] && NEOS_USER=admin
[ -z ${NEOS_PASSWORD} ] && NEOS_PASSWORD=password
[ -z ${NEOS_FIRSTNAME} ] && NEOS_FIRSTNAME=John
[ -z ${NEOS_LASTNAME} ] && NEOS_LASTNAME=Doe
[ -z ${NEOS_SITE} ] && NEOS_SITE=TYPO3.NeosDemoTypo3Org

echo "Neos will be installed with this environment with this vars:"
echo "DB-Name: ${DATABASE_NAME}"
echo "User login: ${NEOS_USER}"
echo "User PW: ${NEOS_PASSWORD}"
echo "User Firstname: ${NEOS_FIRSTNAME}"
echo "User Lastname: ${NEOS_LASTNAME}"
echo "Site package: ${NEOS_SITE}"
echo "Additional Packages: ${PACKAGES}"
echo "in Version: ${VERSION}"
echo "---------"

# Checkout another version if necessary
if [ -n "${VERSION}" ]
	then
		echo "*** Checkout Git at ${VERSION}"
		git checkout ${VERSION}
fi

# Require additional packages
if [ -n "${PACKAGES}" ]
	then
		export IFS=";"
		for package in ${PACKAGES}; do
			echo "Require composer package $package"
			composer require --no-update "$package"
		done
fi

# Install changes if needed
if [ -n "${VERSION}" -o -n "${PACKAGES}" ]
	then
		echo "run composer install now"
		rm composer.lock
		composer --no-dev install
fi

echo "*** Configure Neos' Context"
cp /assets/neos-vhost.conf /etc/apache2/sites-available/neos-vhost.conf

# Create database
mysql -h ${DB_PORT_3306_TCP_ADDR} -u root -p${DB_ENV_MYSQL_ROOT_PASSWORD} -e "CREATE DATABASE IF NOT EXISTS ${DATABASE_NAME} DEFAULT CHARACTER SET utf8"

# Set Context
if [ $CONTEXT="Production" -o $CONTEXT="Development" -o $CONTEXT="Testing" ]
	then
		sed -i s/NEOS_CONTEXT/${CONTEXT}/g /etc/apache2/sites-available/neos-vhost.conf
	else
		export CONTEXT=Production
		sed -i s/NEOS_CONTEXT/${CONTEXT}/g /etc/apache2/sites-available/neos-vhost.conf
fi

echo "*** Activate vhost"
cd /etc/apache2/sites-available/ && a2ensite neos-vhost.conf

echo "*** Updating Settings.yaml"
cp /assets/Settings.yaml /var/www/neos/Configuration/${CONTEXT}/Settings.yaml
cd /var/www/neos/Configuration/${CONTEXT}
sed -i s/DB_HOST/${DB_PORT_3306_TCP_ADDR}/g Settings.yaml
sed -i s/DB_PASSWORD/${DB_ENV_MYSQL_ROOT_PASSWORD}/g Settings.yaml
sed -i s/DB_NAME/${DATABASE_NAME}/g Settings.yaml

# Set inital databases
echo "*** Inital databse migration"
FLOW_CONTEXT=${CONTEXT} /var/www/neos/flow doctrine:migrate

# Import demo site and migrate again
echo "*** Import the TYPO3.Neos demo package and create a new admin user"
FLOW_CONTEXT=${CONTEXT} /var/www/neos/flow site:import --package-key ${NEOS_SITE}
FLOW_CONTEXT=${CONTEXT} /var/www/neos/flow user:create ${NEOS_USER} ${NEOS_PASSWORD} ${NEOS_FIRSTNAME} ${NEOS_LASTNAME} --roles TYPO3.Neos:Administrator
FLOW_CONTEXT=${CONTEXT} /var/www/neos/flow doctrine:migrate

# Flush all caches and warm them up
echo "*** Warmup the cache"
FLOW_CONTEXT=${CONTEXT} /var/www/neos/flow flow:cache:flush
FLOW_CONTEXT=${CONTEXT} /var/www/neos/flow flow:cache:warmup

# Fix all filepermissions
echo "*** Fixing all file permissions"
cd /var/www/neos/ && ./flow flow:core:setfilepermissions www-data www-data www-data

echo "*** You are ready to go - have fun with your new TYPO3 Neos installation!"

# Start apache
exec /usr/sbin/apache2ctl -D FOREGROUND