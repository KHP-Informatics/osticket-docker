# osticket-docker

Create an isolated network for osticket:

```
  docker network create --driver bridge osticket_nw
```

You will need a mysql DB server running on that network:

We'll used the official docker one (https://github.com/docker-library/docs/tree/master/mysql)

```
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

This stores its mysql data in a volume. You can back it up by running another container and copying the contents of the mysql data directory and you can restore it by just starting a new instance with -v /path/to/backup:/var/lib/mysql.


If you need to get into the database and dig around for some reason, find out the IP address of your database with

```
  docker network inspect osticket_nw
```

And then start another container running the mysql client and use that to connect (replacing <IP> with the actual IP):

```
  docker run -it --net=osticket_nw  --rm mysql sh -c 'exec mysql -h<IP> -P3306 -uroot -p"password"'
```

If you don't have proper SSL certs for your server, generate them with something like: 

```
openssl req -new -x509 -nodes -out server.pem -keyout server.key -days 3650 -subj '/CN=localhost'
```

You can now run your osticket container, bind mount your SSL certs and link it to your database:

```
  docker run --name osticket \
             --net osticket_nw \
              -v /tmp/server.key:/usr/local/apache2/conf/server.key \
              -v /tmp/server.pem:/usr/local/apache2/conf/server.pem \
              -p 80:80 -p 443:443 \
              -d  cassj/osticket 
```


