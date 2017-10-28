# docker-postfix

Docker Repository Location : [neilalcoseba/docker-postfix](https://hub.docker.com/r/neilalcoseba/docker-postfix/)

# Building

$ docker build -t docker-postfix .

Change the Timezone :

$ docker build --build-arg TZ='Europe/London' -t postfix .
