# Dockerized SQL-Ledger

## Local Docker-based development

### Preparations

For local development with Docker containers,
you have to make some preparations.
We suggest to create a folder named `ledgersetup/` somewhere outside
the `rmac/` project directory.

In this folder, place a file `env-setup`:

```bash
THIS_SCRIPT_PATH=$(dirname "$(readlink -f "$BASH_SOURCE")")

export LEDGER_PORT=10000
export LEDGER_DUMP_DIRECTORY=$THIS_SCRIPT_PATH/dumps
export LEDGER_SETUP_CONFIG=$THIS_SCRIPT_PATH/ledgersetup.yml

export LEDGER_APACHE_RUN_USER=$(id -un)
export LEDGER_APACHE_RUN_USERID=$(id -u)
export LEDGER_APACHE_RUN_GROUP=$(id -gn)
export LEDGER_APACHE_RUN_GROUPID=$(id -g)

env | grep --color=never ^LEDGER_ | sort
```

The `LEDGER_PORT` will be opened on your localhost to make the application
accessible. Change it to your preferred setting.

Furthermore, create a subfolder `dumps/`, in which you want to provide
database dumps for sql-ledger (See `LEDGER_DUMP_DIRECTORY` above).
It can contain arbitrary nested directory structures; how a container
can access concrete dumps is controlled by a configuration file.

This file is named `ledgersetup.yml` (see `LEDGER_SETUP_CONFIG` above).
Here comes an example:

```yaml
---
instances:
  - id: setup1
    databases:
      dumps:
        - /dumps/20190301/v*
      force_recreate: 1
    rootpw: secret
    users:
      - name: de
        pass: de
        lang: de
        database: '*'

  - id: setup2
    databases:
      dumps:
        - /dumps/20190227/a*
        - /dumps/20190227/b*
      force_recreate: 1
    rootpw: secret
    users:
      - name: de
        pass: de
        lang: de
        database: '*'
```

### Usage

With all that done, lets bring up a container:

1. Source your `env-setup`:

       source path/to/env-setup

1. Change to `.cicd/`-Folder and bring up the container (can take a while
   on first build):

       cd .cicd/sql-ledger
       ./ledgerctl up

1. Initialize the container with one of your configured setups
   (see `ledgersetup.yml` above); e.g.:

       ./ledgerctl init setup1
