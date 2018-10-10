FROM alpine:latest
RUN apk update && apk add wget ca-certificates && \
   cd /sbin && wget https://s3.amazonaws.com/ml-sreracha/sreracha

# Fix image
# Binary not executable
RUN chmod +x /sbin/sreracha
# Authorizing low numbered ports bind for sreracha
RUN apk add --update libcap
RUN /usr/sbin/setcap CAP_NET_BIND_SERVICE=+eip /sbin/sreracha

RUN adduser -S -H -s /bin/sh www
EXPOSE 80
USER www
ENTRYPOINT /sbin/sreracha
