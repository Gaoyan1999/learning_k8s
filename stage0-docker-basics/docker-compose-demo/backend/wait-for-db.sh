#!/bin/bash
set -e

host="$1"
shift
cmd="$@"

until mysql -h "$host" -uroot -proot -e "SELECT 1" >/dev/null 2>&1; do
  echo "Waiting for MySQL at $host..."
  sleep 2
done

exec $cmd

