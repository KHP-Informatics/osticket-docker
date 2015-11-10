FROM httpd
MAINTAINER Cass Johnston <cassjohnston@gmail.com>

RUN apt-get update && apt-get install -yqq  bzip2 curl vim build-essential libapr1-dev libaprutil1-dev libxml2-dev zip mysql-client 

# Create a user & group (apache runs as this user)
RUN groupadd --system osticket 
RUN useradd --system -g osticket osticket 


# Install PHP for this Apache
COPY php-5.6.15.tar.bz2 /tmp/php-5.6.15.tar.bz2
RUN cd /tmp && tar -xvjf php-5.6.15.tar.bz2
RUN cd /tmp/php-5.6.15/ && ./configure --with-apxs2=/usr/local/apache2/bin/apxs  && make && make install

# PHP & Apache configuration
COPY php.ini /usr/local/lib/php.ini
COPY httpd.conf /usr/local/apache2/conf/httpd.conf
COPY httpd-ssl.conf /usr/local/apache2/conf/extra/httpd-ssl.conf
COPY httpd-vhosts.conf /usr/local/apache2/conf/extra/httpd-vhosts.conf

COPY osTicket-v1.9.12.zip  /usr/local/apache2/htdocs/osticket.zip
RUN cd /usr/local/apache2/htdocs && unzip  osticket.zip 
RUN mv /usr/local/apache2/htdocs/upload /usr/local/apache2/htdocs/osticket
RUN chown -R osticket:osticket /usr/local/apache2


# Define default env vars for httpd - you can override these
ENV SERVERNAME localhost
ENV ADMINEMAIL root@localhost


