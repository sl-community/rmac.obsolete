#!/bin/bash

ENV_FILE=~/.sql-ledger.local.env
LINK=.env


if [ -r $ENV_FILE ]; then
    echo "Environment file exists: $ENV_FILE" 1>&2
else
    cat >$ENV_FILE <<EOF
LEDGER_PORT=10000
LEDGER_DUMP_DIRECTORY=
LEDGER_SETUP_CONFIG=

LEDGER_APACHE_RUN_USER=$(id -un)
LEDGER_APACHE_RUN_USERID=$(id -u)
LEDGER_APACHE_RUN_GROUP=$(id -gn)
LEDGER_APACHE_RUN_GROUPID=$(id -g)
EOF
    echo "Environment file created: $ENV_FILE" 1>&2
    echo "Please adjust it to your needs." 1>&2
fi
    
if [ -L $LINK ]; then
    echo "Symbolic link exists: $LINK" 1>&2
else
    ln -s $ENV_FILE $LINK
    echo "Symbolic link created: $LINK -> $(readlink -- "$LINK")" 1>&2
fi

echo
echo "Your setup (via $LINK):"
echo "=============================="
cat $LINK
echo "=============================="
echo

source $LINK

if [ ! -d "$LEDGER_DUMP_DIRECTORY" ]; then
    echo "*** LEDGER_DUMP_DIRECTORY does not exist." 1>&2
    exit 1
fi
