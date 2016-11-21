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
              -d mysql
```

Docs for the mysql container are here - https://hub.docker.com/_/mysql/

If you need to access the database, you can use something like:
```
  docker run -it --rm --net=osticket_nw mysql /usr/bin/mysql -hosticket-mysql -u<username> -p<password>
```



### OSticket Web Server

Put your SSL cert in a named volume. For dev, you can just:

```
  docker run --name=deleteme -it -v osticket-keys:/tmp cassj/osticket-docker /bin/bash
  cd /tmp
  openssl req -new -x509 -nodes -out server.pem -keyout server.key -days 3650 -subj '/CN=localhost'
  exit
  docker rm deleteme
```

Docker 1.9 recommends using named volumes, but until 1.10 (https://github.com/docker/docker/issues/18670) these don't copy over the data from the container image as anonymous volumes did. To work around this for now, create a named data volume by manually copying over the contents:

```
docker run --name=deleteme -it -v osticket-data:/data cassj/osticket-docker:1.10 /usr/bin/rsync -avz /usr/local/apache2/htdocs/osticket/ /data/
docker rm deleteme
```

Start your webserver:

If this is your first run of osticket, specify the settings you want as environment variables. If your oticket-data volume already contains a configured osticket then you can omit the env vars.

```
docker run --name=osticket --net=osticket_nw -v osticket-keys:/usr/local/apache2/conf/ssl-certs -v osticket-data:/usr/local/apache2/htdocs/osticket  -e OSTICKET_URL=192.168.99.100 -e OSTICKET_NAME=MyOSTicketService -e OSTICKET_EMAIL=foo@example.com  -e OSTICKET_ADMIN_EMAIL=bar@example.com -e OSTICKET_ADMIN_FNAME=Kate -e OSTICKET_ADMIN_LNAME=Administrator -e OSTICKET_ADMIN_USERNAME=administrator -e OSTICKET_ADMIN_PASSWORD=password -e OSTICKET_DB_PREFIX=ost_ -e OSTICKET_DB_HOST=osticket-mysql -e OSTICKET_DB_NAME=osticket -e OSTICKET_DB_USER=osticket -e OSTICKET_DB_PASS=password  --log-opt max-size=2m --log-opt max-file=3 -p 80:80 -p 443:443 -d cassj/osticket-docker:1.10
```

OSTICKET_URL   - will try to autodetect if undefined. 
OSTICKET_NAME  - the name of your OSTicket site, e.g. "Bob's Helpdesk"
OSTICKET_EMAIL - the system email (e.g. support@example.com)

OSTICKET_ADMIN_FNAME - Administrator forename
OSTICKET_ADMIN_LNAME - Administrator surname
OSTICKET_ADMIN_EMAIL - Administrator email. Must differ from the system email 
OSTICKET_ADMIN_USERNAME 
OSTICKET_ADMIN_PASSWORD

OSTICKET_DB_PREFIX - Database table prefix. If not defined then defaults to ost_
OSTICKET_DB_HOST - Database host (e.g. osticket-mysql) 
OSTICKET_DB_NAME 
OSTICKET_DB_USER  
OSTICKET_DB_PASS


The setup script will set up the core plugins (https://github.com/osTicket/core-plugins). 
This takes a while, so give it a minute. You can watch it install with 

```
docker logs -f osticket
```
although there is an issue with composer which means you'll see a load of 'Invalid version string' warnings. You can safely ignore them. 

Users can submit tickets at https://$OSTICKET_URL/

You can log into the administration interface with https://$OSTICKET_URL/scp/login.php


### Upgrading

Backup your database before you start:

```
docker run --rm -it -v /wherever/backups:/data --net=osticket_nw mysql /bin/bash -c "/usr/bin/mysqldump -hosticket-mysql -uroot -ppassword osticket > /data/osticket-dbdump-DATE.sql"
```

And backup your oticket data volume too:

``` 
docker run --name=deleteme -it -v osticket-data:/data -v /some/backup/place:/backup cassj/osticket-docker /bin/bash -c "rsync -avz /data/ /backup"
docker rm deleteme
```

Stop the running container but don't delete it until the update has been tested - just rename it

```
  docker stop osticket
  docker rename osticket osticket-DATE
```

Get the version you want from Dockerhub

```
  docker pull cassj/osticket:<tag>
```

OSticket update docs are available at http://osticket.com/wiki/Upgrade_and_migration, and basically involve overwriting your existing OSticket files with new ones, except for include/ost-config.php, so just use a temporary container to do that:

```
docker run --name=deleteme -it -v osticket-data:/data cassj/osticket-docker /bin/bash -c "rsync -avz --exclude include/ost-config.php  /usr/local/apache2/htdocs/osticket/ /data"
docker rm deleteme
```

And start a new osticket instance with your updated data:

```
  docker run --name=osticket --net=osticket_nw -v osticket-keys:/usr/local/apache2/conf/ssl-certs -v osticket-data:/usr/local/apache2/htdocs/osticket --log-opt max-size=2m --log-opt max-file=3 -p 80:80 -p 443:443 -d cassj/osticket-docker 
```

At this point, you should be able to go to https://$OSTICKET_URL/scp and run the upgrader




