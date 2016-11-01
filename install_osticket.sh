#!/bin/sh

cd /tmp
wget "http://osticket.com/sites/default/files/download/osTicket-v1.10-rc.3.zip"
unzip osTicket-v1.10-rc.3.zip
mv upload /usr/local/apache2/htdocs/osticket
cp /usr/local/apache2/htdocs/osticket/include/ost-sampleconfig.php /usr/local/apache2/htdocs/osticket/include/ost-config.php
chown -R osticket:osticket /usr/local/apache2
chmod -R u+r /usr/local/apache2/htdocs/osticket
rm -rf /tmp/osticket*

