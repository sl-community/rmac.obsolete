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
name: setup1
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
* *One* use of the pattern `{{ build_time(%Y%m%d) }}` (or any other strftime expression)
* *One* use of the pattern `{{ latest_nonempty_dir() }}`


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
