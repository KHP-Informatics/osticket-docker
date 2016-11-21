#!/bin/sh

#  fetch php
cd /tmp
wget  http://nz2.php.net/get/php-5.6.27.tar.bz2/from/this/mirror
mv mirror php-5.6.27.tar.bz2
tar -xvjf php-5.6.27.tar.bz2
cd php-5.6.27
# can't find SLL libs
ln -s /usr/lib/x86_64-linux-gnu/libssl.so /usr/lib/libssl.so
ln -s /usr/lib/x86_64-linux-gnu/libcrypto.so /usr/lib/libcrypto.so
# Or the LDAP libs
ln -s /usr/lib/x86_64-linux-gnu/libldap.so /usr/lib/libldap.so
ln -s /usr/lib/x86_64-linux-gnu/liblber.so /usr/lib/liblber.so
# Configure, Compile and Install
./configure --with-apxs2=/usr/local/apache2/bin/apxs --with-gettext --with-mysqli --with-imap --with-zlib --with-gd  --with-curl --with-kerberos --with-imap-ssl --with-openssl --with-ldap --enable-mbstring --enable-intl  
make 
make install
# Clean up
rm -rf /tmp/php*

