#!/bin/sh
# Setup Database Variables

# Create database
mysql -h ${DB_PORT_3306_TCP_ADDR} -u root -p${DB_ENV_MYSQL_ROOT_PASSWORD} -e "CREATE DATABASE IF NOT EXISTS neos DEFAULT CHARACTER SET utf8"

# Search vor context var
if [ -z $CONTEXT ]
	then
		CONTEXT=Production
		export CONTEXT=Production
		cp /assets/neos-prod.conf /etc/apache2/sites-available/neos-prod.conf
		cd /etc/apache2/sites-available/ && a2ensite neos-prod.conf
fi

cp /assets/Settings.yaml /var/www/neos/Configuration/${CONTEXT}/Settings.yaml
cd /var/www/neos/Configuration/${CONTEXT}
sed -i s/DB_HOST/${DB_PORT_3306_TCP_ADDR}/g Settings.yaml
sed -i s/DB_PASSWORD/${DB_ENV_MYSQL_ROOT_PASSWORD}/g Settings.yaml

# Set inital databases
FLOW_CONTEXT=${CONTEXT} /var/www/neos/flow doctrine:migrate

# Import Demo-Backage and migrate again
FLOW_CONTEXT=${CONTEXT} /var/www/neos/flow site:import --package-key TYPO3.NeosDemoTypo3Org
FLOW_CONTEXT=${CONTEXT} /var/www/neos/flow user:create admin password John Doe --roles TYPO3.Neos:Administrator
FLOW_CONTEXT=${CONTEXT} /var/www/neos/flow doctrine:migrate

# Fix all filepermissions and warmul all caches
cd /var/www/neos/ && ./flow flow:core:setfilepermissions root www-data www-data
FLOW_CONTEXT=${CONTEXT} /var/www/neos/flow cache:warmup

exec /usr/sbin/apache2ctl -D FOREGROUND

