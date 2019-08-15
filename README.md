# AngelBox

AngelBox provides a framework for running compositions of docker images.
The obvious tool for this is docker-compose. Ironically, the one thing that
docker-compose is lousy at, is "composition".

Docker-compose prefers one single `yaml` file that specifies a 'composition' of all of your
services. We use a simple method to create this 'composition' that can be applied to any and
every docker image. Each docker image is represented by its own `yaml` file in which all
of the important features are made customisable through variables.

## Docker-Compose-USE <composition.env>

The script `docker-compose-use` creates a `.env` file for `docker-compose` to use.
It processes a `composition.env` file which you provide to define the 
composition - the list of services, and values for the variables. 

```
#> docker-compose-use ./config-example/server.env
```
where `./config-example/server.env` is similar to:
```
MYSQL_IMAGE=mariadb/10.4-bionic
MYSQL_PORTS_3306=4000

COMPOSE_FILE=box-begin.yml:\
    hub/official/mysql.yml:\
    hub/official/mysql/+file-secrets.yml:\
    box-end.yml
```

#### Conventions

- Additions/Variations are provided in a folder with the name of the service.
- Overrides are indicated by the `+` in the filename.
- comments and blank lines are ignored.
- Variables are named (strictly) according to their position in the `yaml` structure.
	- Except Volumes is translated to VOLUME(named volume)/FILE/DIR
	- And ENVIRONMNENT can be ommitted
	
## Docker-Compose-USE <composition.env> <deployment.env>

A second `env` file can be provided with additional values that relate to a specific
deployment instance, which can be used like so.

```
docker-compose-use my-services.env $(hostname).env
```
