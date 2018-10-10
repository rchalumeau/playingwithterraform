FROM alpine:latest
RUN apk update &amp;&amp; apk add wget ca-certificates &amp;&amp; \
   cd /sbin &amp;&amp; wget https://s3.amazonaws.com/ml-sreracha/sreracha
RUN adduser -S -H -s /bin/sh www
EXPOSE 80
USER www
ENTRYPOINT /sbin/sreracha
