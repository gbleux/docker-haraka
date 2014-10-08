# VERSION           0.0.4
# DOCKER-VERSION    1.2.0

FROM node:0.10
MAINTAINER Gordon Bleux <gordon.bleux+dh@gmail.com> (@gbleux)

# node-gyp emits lots of warnings if HOME is set to /
ENV HOME /tmp
ENV HARAKA_VERSION 2.5.0

# install haraka binary to /usr/local/bin
# (which is already part of PATH)
RUN npm install -g Haraka@$HARAKA_VERSION
RUN haraka --install /app

# the application is not started as this user,
# but Haraka can be configured to drop its privileges
# via smtp.ini
RUN groupadd -r haraka && \
    useradd --comment "Haraka Server User" \
            --home /app \
            --shell /bin/false \
            --gid haraka \
            -r \
            -M \
            haraka

COPY haraka-wrapper /usr/local/bin/haraka-wrapper
COPY config /app/config
RUN mkdir -p /app && \
    mkdir -p /logs && \
    mkdir -p /data && \
    chmod -R 0777 /logs && \
    chmod -R 0777 /data && \
    chown -R haraka:haraka /app /logs /data

ENV HOME /app
ENV HARAKA /app

WORKDIR /app
VOLUME ["/logs", "/data"]

EXPOSE 25

ENTRYPOINT ["/usr/local/bin/haraka-wrapper", "--configs", "/app"]
CMD []