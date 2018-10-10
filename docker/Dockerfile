FROM alpine:latest
RUN apk update && apk add wget ca-certificates && \
   cd /sbin && wget https://s3.amazonaws.com/ml-sreracha/sreracha

# Fix image
# Binary not executable
RUN chmod +x /sbin/sreracha

RUN adduser -S -H -s /bin/sh www
EXPOSE 80
USER www
ENTRYPOINT /sbin/sreracha
