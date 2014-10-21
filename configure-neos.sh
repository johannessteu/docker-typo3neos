#!/bin/sh
# Setup Database Variables

# Checkout Neos version if provided
cd /var/www/neos

if [ -n "${VERSION}" ]
	then
		echo "--- Try to checkout Git at ${VERSION}"
		git checkout ${VERSION}
		rm composer.lock
		composer --no-dev install
fi

# Create database
mysql -h ${DB_PORT_3306_TCP_ADDR} -u root -p${DB_ENV_MYSQL_ROOT_PASSWORD} -e "CREATE DATABASE IF NOT EXISTS neos DEFAULT CHARACTER SET utf8"

echo "--- Configure Neos' Context"
cp /assets/neos-vhost.conf /etc/apache2/sites-available/neos-vhost.conf

# Set Context
if [ $CONTEXT="Production" -o $CONTEXT="Development" -o $CONTEXT="Testing" ]
	then
		sed -i s/NEOS_CONTEXT/${CONTEXT}/g /etc/apache2/sites-available/neos-vhost.conf
	else
		export CONTEXT=Production
		sed -i s/NEOS_CONTEXT/${CONTEXT}/g /etc/apache2/sites-available/neos-vhost.conf
fi

echo "--- Activate vhost"
cd /etc/apache2/sites-available/ && a2ensite neos-vhost.conf

echo "--- Updating Settings.yaml"
cp /assets/Settings.yaml /var/www/neos/Configuration/${CONTEXT}/Settings.yaml
cd /var/www/neos/Configuration/${CONTEXT}
sed -i s/DB_HOST/${DB_PORT_3306_TCP_ADDR}/g Settings.yaml
sed -i s/DB_PASSWORD/${DB_ENV_MYSQL_ROOT_PASSWORD}/g Settings.yaml

# Set inital databases
echo "--- Inital databse-migration"
FLOW_CONTEXT=${CONTEXT} /var/www/neos/flow doctrine:migrate

# Import Demo-Backage and migrate again
echo "--- Import the TYPO3.Neos Demo-Package and create a new admin user"
FLOW_CONTEXT=${CONTEXT} /var/www/neos/flow site:import --package-key TYPO3.NeosDemoTypo3Org
FLOW_CONTEXT=${CONTEXT} /var/www/neos/flow user:create admin password John Doe --roles TYPO3.Neos:Administrator
FLOW_CONTEXT=${CONTEXT} /var/www/neos/flow doctrine:migrate

# Flush all caches and warm them up
echo "--- Warmup the cache"
FLOW_CONTEXT=${CONTEXT} /var/www/neos/flow flow:cache:flush
FLOW_CONTEXT=${CONTEXT} /var/www/neos/flow flow:cache:warmup

# Fix all filepermissions and warmul all caches
echo "--- Fixing all file permissions"
cd /var/www/neos/ && ./flow flow:core:setfilepermissions www-data www-data www-data

echo "--- You are ready to go - have fun wiht your new TYPO3 Neos installation!"
exec /usr/sbin/apache2ctl -D FOREGROUND