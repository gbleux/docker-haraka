# Haraka SMTP server image

Based on the [node] baseimage, it provides a basic [Haraka] installation.
The developer is left with the task of [configuring] the server instance
and providing additional [plugins].

[node]: https://registry.hub.docker.com/_/node/
[Haraka]: http://haraka.github.io
[configuring]: http://haraka.github.io/manual/tutorials/SettingUpOutbound.html
[plugins]: http://haraka.github.io/manual/Tutorial.html

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

With the custom Haraka configuration (_config_), plugins (_pluins_) and 
documentation (_docs_) in place, the Dockerfile must only inherit from
**gbleux/haraka**. The current directory will be [copied][COPY] into the
container [upon build][ONBUILD] time. Any dependencies specified in
_package.json_ will be installed as well.

If any plugin opens a port in a addition to port 25, it must be exposed
in the Dockerfile.

    FROM gbleux/haraka
    # SMTPS
    EXPOSE 465

Once this is done, a new Docker image can be created:

> docker build -t \<IMAGE\> .

An simple implementation can be found in the _example_ directory.

[COPY]: http://docs.docker.com/reference/builder/#copy
[ONBUILD]: http://docs.docker.com/reference/builder/#onbuild


## Usage

The Docker image is set up to run a Haraka server instance but can also
be used for other tasks, such as querying the outbound queue or listing
the enabled plugins. Haraka is installed under */app*, although the path
is already provided to the script via the [ENTRYPOINT] directive.

>docker run -d -P \<IMAGE\>

### Security

The service instance inside the container is started as _root_ user.
The server configuration shipped with the container is instructed to
drop any privileges and switch to the system user _haraka_. This should
be considered, when providing a custom **smtp.ini** configuration.

### Data persistence

The container provides two [volumes][VOLUME]:

* /logs
    + The server will write log messages into this directory.
    + The path is read from the Haraka **smtp.ini** configuration
* /data
    + Contains any data created during runtime
    + Out of the box, only the outbound queue is stored there
    + Plugins can use this directory to share data with  
      the host or other containers

[ENTRYPOINT]: http://docs.docker.com/reference/builder/#entrypoint
[VOLUME]: http://docs.docker.com/reference/builder/#volume