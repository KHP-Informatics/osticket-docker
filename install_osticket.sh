#!/bin/sh

cd /tmp
wget "http://osticket.com/sites/default/files/download/osTicket-v1.8.12.zip"
unzip -d osticket osTicket-v1.8.12.zip
mv osticket/upload /usr/local/apache2/htdocs/osticket
cp /usr/local/apache2/htdocs/osticket/include/ost-sampleconfig.php /usr/local/apache2/htdocs/osticket/include/ost-config.php
chown -R osticket:osticket /usr/local/apache2

rm -rf /tmp/*

