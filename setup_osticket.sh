#!/bin/bash

# Only if we haven't already set everything up:
if [ -d /usr/local/apache2/htdocs/osticket/setup ] 
then

  # start the webserver in the bg
  httpd-foreground &
  PID=$!
  echo "$PID"

  # give it a minute to get going
  sleep 5 

  # call the osticket setup script with user defined params
  curl -vvv -k -X POST -F s=install -F fname=$OSTICKET_ADMIN_FNAME -F lname=$OSTICKET_ADMIN_LNAME  -F admin_email=$OSTICKET_ADMIN_EMAIL -F name=$OSTICKET_NAME  -F email=$OSTICKET_EMAIL -F username=$OSTICKET_ADMIN_USERNAME -F passwd=$OSTICKET_ADMIN_PASSWORD -F passwd2=$OSTICKET_ADMIN_PASSWORD -F prefix=$OSTICKET_DB_PREFIX -F dbhost=$OSTICKET_DB_HOST -F dbname=$OSTICKET_DB_NAME -F dbuser=$OSTICKET_DB_USER -F dbpass=$OSTICKET_DB_PASS  -F lang_id=en_US -F submit="Install Now" https://$OSTICKET_URL/setup/install.php

  # and install the plugins
  cd /usr/local/apache2/htdocs/osticket/include/plugins && git clone https://github.com/osTicket/core-plugins.git && mv core-plugins/* . && rm -rf core-plugins && sed -ie 's/pear-pear\/Net/pear-pear.php.net\/Net/' auth-ldap/plugin.php && rm -rf storage-s3  && php make.php hydrate

  # stop the webserver
  kill $PID

  # delete the setup dir
  rm -rf /usr/local/apache2/htdocs/osticket/setup

fi

# start the webserver in the foreground
httpd-foreground
