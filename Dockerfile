FROM alpine:latest as build
RUN apk add --no-cache go
RUN apk add --no-cache git
RUN go get github.com/koron/go-ssdp
RUN go get github.com/gorilla/websocket
RUN go get github.com/kardianos/osext
RUN git clone https://github.com/xteve-project/xTeVe.git /tmp/xTeVe
WORKDIR /tmp/xTeVe
RUN apk add --no-cache gcc musl-dev
RUN go build xteve.go

FROM alpine:latest
MAINTAINER alturismo alturismo@gmail.com

# Add Bash shell & dependancies
RUN apk add --no-cache bash busybox-suid su-exec ffmpeg vlc curl ca-certificates tzdata socat
# Timezone (TZ)
ENV TZ=UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Volumes
VOLUME /config
VOLUME /root/.xteve
VOLUME /tmp/xteve

RUN sed -i 's/geteuid/getppid/' /usr/bin/vlc

# Add xTeve and guide2go
#RUN wget https://github.com/xteve-project/xTeVe-Downloads/raw/master/xteve_linux_arm64.zip -O temp.zip; unzip temp.zip -d /usr/bin/; rm temp.zip
COPY --from=build /tmp/xTeVe/xteve /usr/bin
ADD sample_cron.txt /
ADD sample_xteve.txt /
ADD cronjob.sh /
ADD entrypoint.sh /

# Set executable permissions
RUN chmod +x /entrypoint.sh /cronjob.sh /usr/bin/xteve

# Expose Port
EXPOSE 34400

USER daemon
# Entrypoint
ENTRYPOINT ["./entrypoint.sh"]
