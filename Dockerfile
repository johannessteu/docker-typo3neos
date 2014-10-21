# DOCKER-VERSION 1.2.0

FROM ubuntu
MAINTAINER Johannes Steu <js@johannessteu.de>

# Setup apache2
RUN apt-get update && apt-get -y install git apache2 php5 php5-mysql mysql-client curl && apt-get clean
RUN a2enmod rewrite
RUn a2dissite 000-default.conf

RUN echo 'date.timezone = "Europe/Berlin"' >> /etc/php5/cli/php.ini
RUN echo 'date.timezone = "Europe/Berlin"' >> /etc/php5/apache2/php.ini

# install composer
RUN curl -s https://getcomposer.org/installer | php &&  mv composer.phar /usr/local/bin/composer

# Checkout typo3neos
RUN cd /var/www && git clone http://git.typo3.org/Neos/Distributions/Base.git neos
RUN cd /var/www/neos && git checkout 1.1.2 && composer install

ADD configure-neos.sh /configure-neos.sh
ADD assets/Settings.yaml /assets/Settings.yaml
ADD assets/neos-vhost.conf /assets/neos-vhost.conf

RUN chmod +x /configure-neos.sh

# run config script
CMD ["/configure-neos.sh"]