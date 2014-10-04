# VERSION           0.0.2
# DOCKER-VERSION    1.2.0

FROM node
MAINTAINER Gordon Bleux <gordon.bleux+dh@gmail.com> (@gbleux)

# node-gyp emits lots of warnings if HOME is set to /
ENV HOME /tmp

# install haraka binary to /usr/local/bin
# (which is already part of PATH)
RUN npm install -g Haraka
RUN haraka --install /app

COPY docker-entrypoint.sh /usr/local/bin/haraka-docker
RUN chmod 0755 /usr/local/bin/haraka-docker

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

ENTRYPOINT ["/usr/local/bin/haraka-docker"]
CMD []

ONBUILD COPY . /app
ONBUILD RUN npm install
