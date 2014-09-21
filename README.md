# Haraka SMTP server image

Based on the [node] baseimage, it provides a basic [Haraka] installation.
The developer is left with the task of [configuring] the server instance
and providing additional [plugins].

[node]: asdas (NodeJS Docker Image)
[Haraka]: http://haraka.github.io (Haraka SMTP Homepage)
[configuring]: http://haraka.github.io/manual/tutorials/SettingUpOutbound.html (Configuring Haraka)
[plugins]: http://haraka.github.io/manual/Tutorial.html (Writing Haraka Plugins)

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

Once the configuration and plugin files are in place, a simple
Dockerfile can be created to run a Haraka instance.

Apart from the image inheritance instruction (**FROM gbleux/haraka**),
at least the port forwarding instruction (**EXPOSE 25**) should be present.
The value should match the Haraka configuration, which defaults to *25*.

Once this is done, a new Docker image can be created:

> docker build -t \<IMAGE\> .

An simple implementation can be found in the _example_ directory.

## Usage

The Docker image is set up to run a Haraka server instance but can also
be used for other tasks, such as querying the outbound queue or listing
the enabled plugins. Haraka is installed under */usr/local/share/haraka*,
although the path is already provided to the script via the [ENTRYPOINT]
directive.

>docker run -d -P \<IMAGE\>

[ENTRYPOINT]: http://docs.docker.com/reference/builder/#entrypoint