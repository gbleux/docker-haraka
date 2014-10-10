# Haraka SMTP server image

Based on the [node] baseimage, it provides a basic [Haraka] installation.
The developer is left with the task of [configuring] the server instance
and providing additional [plugins].

The following versions are used:

* node container: [0.10][node-version]
* Haraka: [2.5.0][haraka-version]

[node]: https://registry.hub.docker.com/_/node/
[Haraka]: http://haraka.github.io
[configuring]: http://haraka.github.io/manual/tutorials/SettingUpOutbound.html
[plugins]: http://haraka.github.io/manual/Tutorial.html
[haraka-version]: https://github.com/baudehlo/Haraka/tree/v2.5.0
[node-version]: https://github.com/docker-library/node/tree/master/0.10

## Configuration

The Docker container will be provisioned with the content of the directory
of the Dockerfile. Haraka is only interested in three directories:

* docs  
  Documentation for plugins.
* config  
  Configuration files for Haraka and its plugins
* plugins  
  Haraka plugins in addition to the built-ins.

At least the plugin configuration (*config/plugins*) and host list 
(*config/host_list*) should be present for Haraka to function properly.

If the plugins have any third-party dependencies, a *package.json* file
should be present, which specifies those. They will be installed as part
of the image during the build process.

## Assembly

The Dockerfile provides a daemon user (_haraka_), a Haraka environment
under _/app_ with persistence volumes in _/data_ and _/logs_. The only
port exposed by default is **25**. If any plugin opens additional ports
, they must be exposed in the Dockerfile.

    FROM gbleux/haraka:latest
    # SMTPS
    EXPOSE 465

Once this is done, a new Docker image can be created:

> docker build -t $USER/haraka .

### onbuild

With the custom Haraka configuration (_config_), plugins (_pluins_) and 
documentation (_docs_) in place, the Dockerfile must only inherit from
**gbleux/haraka**. The current directory will be [copied][COPY] into the
container [upon build][ONBUILD] time. Any dependencies specified in
_package.json_ will be installed as well.

An simple implementation can be found in the _example_ directory.

[COPY]: http://docs.docker.com/reference/builder/#copy
[ONBUILD]: http://docs.docker.com/reference/builder/#onbuild


## Usage

The Docker image is set up to run a Haraka server instance but can also
be used for other tasks, such as querying the outbound queue or listing
the enabled plugins. Haraka is installed under */app*, although the path
is already provided to the script via the [ENTRYPOINT] directive.

>docker run -d -P $USER/haraka

The entrypoint script will run `haraka` by default but can be instructed
to run arbitrary commands as well.

>docker run -ti $USER/haraka /bin/bash -l

### Security

The service instance inside the container is started as _root_ user.
The server configuration shipped with the container is instructed to
drop any privileges and switch to the system user _haraka_. This should
be considered, when providing a custom **smtp.ini** configuration.

### Data persistence

The container provides two [volumes][VOLUME]:

* **/logs**
    + The server will write log messages into this directory.
    + The path is read from the Haraka **smtp.ini** configuration
* **/data**
    + Contains any data created during runtime
    + Out of the box, only the outbound queue is stored there
    + Plugins can use this directory to share data with  
      the host or other containers

When mounting the volumes, the write permissions for the Haraka user
must be preserved. The easiest way is to make the directory on the
host world readable. Otherwise the Docker entrypoint script can
changes ownership and permissions of the directory from inside the
container. _DOCKER_VOLUMES_CHOWN_ controls the target ownership. Its
value is passed to chown (1) and can either be a user or user:group pair.
Similar _DOCKER_VOLUMES_CHMOD_ can hold the permission flags for the
volumes. Changes to the volume ownership and permission flags are only
made if the respective environment variable is set (e.g. via Dockerfile
[ENV] instruction)

[ENTRYPOINT]: http://docs.docker.com/reference/builder/#entrypoint
[VOLUME]: http://docs.docker.com/reference/builder/#volume
[ENV]: http://docs.docker.com/reference/builder/#env

### Logging

Haraka is run with a wrapper inside the container. Its purpose (among other)
things, is to write log messages to both stdout and the persistence volume
(_/logs_). Logs can either be inspected with `docker logs` or by mounting
_/logs_ and `tail`-ing **/logs/haraka.log**.
Upon startup the wrapper script will perform a logrotation. The current
log is named **/logs/haraka-$DATE.log**. A symbolic link named
**haraka.log** is created alongside it. The date (1) format for the logfile
name can be changes using the environment variable _HARAKA_LOG_DATE_FORMAT_.