# osticket-docker


## To Build


Default httpd.conf assumes ssl (change httpd.conf if you like)

Then just docker build -t me/whatever .


## To Run

### Database

Setup a mysql database for OSticket to use (and, if you like, an isolated network for your containers to communicate over). For example:

```
  docker network create --driver bridge osticket_nw
  docker pull mysql
  docker run --name osticket-mysql \
              -e MYSQL_ROOT_PASSWORD=password \
              -e MYSQL_DATABASE=osticket \
              -e MYSQL_USER=osticket \
              -e MYSQL_PASSWORD=password \
              --net=osticket_nw \
              -d mysql:5.7
```

Changing the root and user passwords, obvs.

Docs for the mysql container are here - https://hub.docker.com/_/mysql/

If you need to access the database, you can use something like:
```
  docker run -it --rm --net=osticket_nw mysql /usr/bin/mysql -hosticket-mysql -u<username> -p<password>
```



### OSticket Web Server

Put your SSL cert in a named volume. For dev, you can just:

```
  docker run --name=deleteme -it -v osticket-keys:/tmp cassj/osticket /bin/bash
  cd /tmp
  openssl req -new -x509 -nodes -out server.pem -keyout server.key -days 3650 -subj '/CN=localhost'
  exit
  docker rm deleteme
```

Docker 1.9 recommends using named volumes, but until 1.10 (https://github.com/docker/docker/issues/18670) these don't copy over the data from the container image as anonymous volumes did. To work around this for now, create a named data volume by manually copying over the contents:

```
docker run --name=deleteme -it -v osticket-data:/data cassj/osticket-docker /usr/bin/rsync -avz /var/www/dokuwiki/ /data/
docker rm deleteme
```

Docker 1.9 recommends using named volumes, but until 1.10 (https://github.com/docker/docker/issues/18670) these don't copy over the data from the container image as anonymous volumes did. To work around this for now, create a named data volume by manually copying over the contents:

```
docker run --name=deleteme -it -v osticket-data:/data cassj/osticket-data /usr/bin/rsync -avz /var/www/dokuwiki/ /data/
docker rm deleteme
```



The OSticket container stores it's osticket data in a volume, so if you create a data container, 
then you can just --volumes-from. Otherwise your config data won't persist through an osticket 
container restart. You might as well pass your SSL certs in here too  

```
docker run --name osticket-data \
           --net osticket_nw \
            -v /tmp/server.key:/usr/local/apache2/conf/server.key \
            -v /tmp/server.pem:/usr/local/apache2/conf/server.pem \
           cassj/osticket-docker:latest \
           /bin/echo 'Data Container Ready'
```

You can now run your osticket container, bind mount your SSL certs and link it to your database.

You'll need to define some environment variables to configure your OSTicket: 

OSTICKET_URL   - will try to autodetect if undefined. 
OSTICKET_NAME  - the name of your OSTicket site, e.g. "Bob's Helpdesk"
OSTICKET_EMAIL - the system email (e.g. support@example.com)

OSTICKET_ADMIN_FNAME - Administrator forename
OSTICKET_ADMIN_LNAME - Administrator surname
OSTICKET_ADMIN_EMAIL 
OSTICKET_ADMIN_USERNAME 
OSTICKET_ADMIN_PASSWORD

OSTICKET_DB_PREFIX - Database table prefix. If not defined then defaults to ost_
OSTICKET_DB_HOST - Database host (e.g. osticket-mysql) 
OSTICKET_DB_NAME 
OSTICKET_DB_USER  
OSTICKET_DB_PASS



```
  docker run --name osticket \
             --hostname osticket \
             --net osticket_nw \
             --volumes-from osticket-data \
              -e OSTICKET_URL=192.168.99.100 \
              -e OSTICKET_NAME=MyOSTicketService \
              -e OSTICKET_EMAIL=support@example.com \
              -e OSTICKET_ADMIN_EMAIL=admin@example.com\
              -e OSTICKET_ADMIN_FNAME=Kate\
              -e OSTICKET_ADMIN_LNAME=Administrator \
              -e OSTICKET_ADMIN_USERNAME=administrator \
              -e OSTICKET_ADMIN_PASSWORD=password \
              -e OSTICKET_DB_PREFIX=ost_ \
              -e OSTICKET_DB_HOST=osticket-mysql \
              -e OSTICKET_DB_NAME=osticket \
              -e OSTICKET_DB_USER=osticket \
              -e OSTICKET_DB_PASS=password \
              -p 80:80 -p 443:443 \
              -d cassj/osticket-docker:latest 
```


The setup script will set up the core plugins (https://github.com/osTicket/core-plugins). 
You might need to give it a minute after startup to get the plugins initialised. THey can't
be installed until after the system is setup though.

Users can submit tickets at https://$OSTICKET_URL/

You can log into the administration interface with https://$OSTICKET_URL/scp/login.php


### Upgrading

Backup your database before you start:

```
docker run --rm -it -v /wherever/backups:/data --net=osticket_nw mysql /bin/bash -c "/usr/bin/mysqldump -hosticket-mysql -uroot -ppassword osticket > /data/osticket-dbdump-DATE.sql"
```

Stop the running container but don't delete it until the update has been tested - just rename it

  docker stop osticket
  docker rename osticket osticket-DATE

Get the version you want from Dockerhub

  docker pull cassj/osticket:<tag>

OSticket update docs are available at http://osticket.com/wiki/Upgrade_and_migration, and basically involve overwriting your existing OSticket files with new ones. 
