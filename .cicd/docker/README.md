# Dockerized SQL-Ledger

In this directory you find a bunch of related .yml-files for use with
`docker-compose`.

The base of everything is `base.yml`, but it always has to be exented with
further .yml files.

`base.yml` can be customized with the following environment variables:

* `LEDGER_DOCUMENT_ROOT` (Default: `/srv/www/sql-ledger`)
* `LEDGER_ADMIN_PASSWORD` (Default: `secret`)
* `LEDGER_POSTGRES_USER` (Default: `sql-ledger`)


## Local development

With

```sh
docker-compose -f base.yml -f web.local.yml up -d
```

you would get a basic web image without database, but at first you
*have* to set a few environment variables for which no reasonable default
can be given.

to be continued...

