#!/bin/sh -x
set -e
echo "Inicializar Proyecto"

df -h
pwd
ls -l /

/start.sh
/install.sh

exec "$@";