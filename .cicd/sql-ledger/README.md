# Dockerized SQL-Ledger

## Local Docker-based development

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
