FROM alpine:3.20
RUN apk add --no-cache curl netcat-openbsd busybox-extras && mkdir -p /www
COPY probe.sh /probe.sh
RUN chmod +x /probe.sh
EXPOSE 8080
CMD ["/bin/sh","-c","/probe.sh; exec busybox httpd -f -p 8080 -h /www"]
