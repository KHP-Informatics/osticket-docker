#!/bin/bash

# start the webserver in the bg
httpd-foreground &
PID=$!
echo "$PID"

# give it a minute to get going
sleep 5

# call the osticket setup script with user defined params
curl -vvv -k -X POST -F s=install -F fname=$OSTICKET_ADMIN_FNAME -F lname=$OSTICKET_ADMIN_LNAME  -F admin_email=$OSTICKET_ADMIN_EMAIL -F name=$OSTICKET_NAME  -F email=$OSTICKET_EMAIL -F username=$OSTICKET_ADMIN_USERNAME -F passwd=$OSTICKET_ADMIN_PASSWORD -F passwd2=$OSTICKET_ADMIN_PASSWORD -F prefix=$OSTICKET_DB_PREFIX -F dbhost=$OSTICKET_DB_HOST -F dbname=$OSTICKET_DB_NAME -F dbuser=$OSTICKET_DB_USER -F dbpass=$OSTICKET_DB_PASS  -F lang_id=en_US -F submit="Install Now" https://$OSTICKET_URL/setup/install.php

# stop the webserver
kill $PID

# start the webserver in the foreground
httpd-foreground
