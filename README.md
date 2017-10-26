# docker-postfix

Docker Repository Location : [neilalcoseba/docker-postfix](https://hub.docker.com/r/neilalcoseba/docker-postfix/)

# Building

$ docker build -t docker-postfix .

Change the user name :

$ docker build --build-arg USER_NAME=<NEW_USER_NAME> -t postfix .

Change the Timezone :

$ docker build --build-arg TZ='Europe/London' -t postfix .
