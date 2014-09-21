# VERSION           0.0.1
# DOCKER-VERSION    1.2.0

FROM node
MAINTAINER Gordon Bleux <gordon.bleux+dh@gmail.com> (@gbleux)

RUN npm install -g Haraka
RUN haraka --install /usr/local/share/haraka

WORKDIR /usr/local/share/haraka
ENTRYPOINT ["haraka", "--configs", "/usr/local/share/haraka"]
CMD []

ONBUILD COPY . /usr/local/share/haraka
ONBUILD RUN npm install
