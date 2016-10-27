#!/bin/sh

cd /tmp
#wget "https://github.com/osTicket/osTicket/archive/1.9.x.zip"
#unzip -d osticket 1.9.x.zip
#mv osticket/osTicket-1.9.x /usr/local/apache2/htdocs/osticket
wget "http://osticket.com/sites/default/files/download/osTicket-v1.9.14.zip"
unzip -d osticket osTicket-v1.9.14.zip
mv osticket/upload /usr/local/apache2/htdocs/osticket
cp /usr/local/apache2/htdocs/osticket/include/ost-sampleconfig.php /usr/local/apache2/htdocs/osticket/include/ost-config.php
chown -R osticket:osticket /usr/local/apache2
chmod -R u+r /usr/local/apache2/htdocs/osticket
rm -rf /tmp/osticket*

