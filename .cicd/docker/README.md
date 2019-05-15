# Dockerized SQL-Ledger

This directory contains

* a bunch of related .yml-files for use with `docker-compose`
* some convenience-scripts

## Local development

Enter the this folder (`.cicd/docker`).

Before you can start working with `docker-compose`, you
have to set a few environment variables.

The preferred way is a `.env` file, but for persistance reasons we suggest
the .env file to be just a symbolic link to, say, `~/.sql-ledger.local.env`.

The `local-env-setup.sh` script will help you with that. Just run it and
adjust the values in the created file to your needs.
You should focus on these three:

* `LEDGER_PORT`: For portmapping to the web container on localhost
* `LEDGER_DUMP_PATH`: Directory containing your database dumps
* `LEDGER_CONFIG_PATH`: Directory containing setup configs (more on this later)



### Basic development container without database:

```sh
COMPOSE="docker-compose -f web.local.yml"
$COMPOSE up -d --build --force-recreate
$COMPOSE exec web ledgersetup.pl --initweb
```

(The admin password will be `secret`; you can choose another one with
`--rootpw PASSWORD`.)



### Basic development container with database:

To populate your SQL-Ledger with data and user information, you need a dump
and a config. E.g. this `setup1.yml` in your configs folder:

```yaml
---
dumps:
  - 20190507/somedump*
  - 20190507/someotherdump*
force_recreate: 1
users:
  - { name: de, pass: de, lang: de }
  - { name: gb, pass: gb, lang: gb }
```

When specifying a dump path, the following is allowed:

* Shell globbing with "`*`"
* Use of the pattern `{{ build_time(%Y%m%d) }}` (or any other strftime expression)
* *One* use of the pattern `{{ latest_nonempty_dir() }}`
* Use of the pattern `{{ param(KEY) }}` 


```sh
COMPOSE="docker-compose -f web.local.yml -f db.local.yml"
$COMPOSE up -d --build --force-recreate
$COMPOSE exec web ledgersetup.pl --initweb --setup setup1.yml
```

The tool `ledgerctl` is a convenience wrapper for these:

```sh
./ledgerctl up
./ledgerctl setup setup1.yml
```

`ledgerctl` is also very handy for testing SQL statements in
`mojo/lib/SL/Model/SQL/resources`:

```sh
./ledgerctl query 
Usage: /usr/local/bin/ledgerquery.pl USERNAME  YAML/KEY  [BIND_PARAMS...]

./ledgerctl query de test/test1
7
```

(this executes the `test1` statement in `test.yml`.)


## Deploying production containers with Jenkins:

The reference production setup is a Linux host with Docker-CE, and
Jenkins+Traefik running as Docker containers.

The following environment variables with appropriate values
are required in the Jenkins container:

* `DOCKER_HOST`: So that `docker` and `docker-compose` commands run seamlessly
* `LEDGER_HOST`: Official hostname for accessing the SQL-Ledger instances
* `LEDGER_DUMP_PATH`: Path *on the host* where dumps are accessible
* `LEDGER_CONFIG_PATH`: Path *on the host* where setup configs are accessible

In Jenkins you can add a *Pipeline Job*.
Please choose a "simple" job name, because it will be part of the sub-URL
that Traefik uses to route requests to your final container.

In the configuration section, Use "Pipeline script from SCM"
(`.cicd/jenkins/colonia50/Jenkinsfile.rmac-default` or something similar).

Finally, create a YAML setup config in your `LEDGER_CONFIG_PATH` folder.
It must be named `_JOBNAME_.yml` to be found by `ledgersetup.pl`.

You can also use build parameters; they are delivered to `ledgersetup.pl`
and are currently only useable in dumps paths (`{{ param(KEY) }}` ).
