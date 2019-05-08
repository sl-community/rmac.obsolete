# Overview

Contents of this directory:

* `Jenkinsfile.*`

    For use with Jenkins (Groovy scripted pipeline)

* `sql-ledger/`

    Docker- and `docker-compose`-related stuff


## Jenkins prerequisites

On the Jenkins host, a few environment variables must be set:

`DOCKER_HOST` and `DOCKER_TLS` (if needed). Just make sure that a `docker` or
`docker-compose` command does its work on the intended Docker host.

`LEDGER_HOST`: Hostname under which your target container is reachable.
This is only relevant if you use Traefik as an reverse proxy.

`LEDGER_DUMP_DIRECTORY`: Path on your Docker host, where database dumps are
accessible

`LEDGER_SETUP_CONFIG`: Path to the ledgersetup config file on your host


## Docker-related stuff

See [sql-ledger/README.md](sql-ledger/README.md)
