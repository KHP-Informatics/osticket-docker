# osticket-docker

Create an isolated network for osticket. Example using the bridge network driver (overlay should also work):

```
  docker network create --driver bridge osticket_nw
```

You will need a mysql DB server running on that network:

We'll used the official docker one (https://github.com/docker-library/docs/tree/master/mysql)

```
  docker pull mysql
  docker run --name osticket-mysql \
             --hostname osticket-mysql \
              -e MYSQL_ROOT_PASSWORD=password \
              -e MYSQL_DATABASE=osticket \
              -e MYSQL_USER=osticket \
              -e MYSQL_PASSWORD=password \
              --net=osticket_nw \
              -d mysql:5.7
```

Changing the root and user passwords, obvs.

This stores its mysql data in a volume. You can back it up by running another container and copying the contents of the mysql data directory and you can restore it by just starting a new instance with -v /path/to/backup:/var/lib/mysql.


If you need to get into the database and dig around for some reason, find out the IP address of your database with

```
  docker network inspect osticket_nw
```

And then start another container running the mysql client and use that to connect (replacing <IP> with the actual IP):

```
  docker run -it --net=osticket_nw  --rm cassj/osticket sh -c 'exec mysql -hosticket-mysql  -uosticket -p"password"'
```

If you don't have proper SSL certs for your server, generate them with something like: 

```
openssl req -new -x509 -nodes -out server.pem -keyout server.key -days 3650 -subj '/CN=localhost'
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


