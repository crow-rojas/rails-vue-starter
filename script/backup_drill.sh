#!/bin/sh
# Restore drill, run with `bin/kamal backup-drill` inside the backup accessory: restores the latest
# backup into a scratch database, reports what it holds and drops it. The live database is never
# touched, unlike the image's restore.sh, which restores over it.
set -eu
. /env.sh

scratch="${POSTGRES_DATABASE}_restore_drill"
conn="-h $POSTGRES_HOST -p $POSTGRES_PORT -U $POSTGRES_USER"
prefix="s3://${S3_BUCKET}/${S3_PREFIX}"

# The decrypted dump is a plaintext copy of production: remove it, and the scratch database, on any exit.
trap 'rm -f /tmp/drill.dump /tmp/drill.dump.gpg; dropdb $conn --if-exists "$scratch"' EXIT

key=$(aws $aws_args s3 ls "${prefix}/${POSTGRES_DATABASE}" | sort | tail -n 1 | awk '{ print $4 }')
[ -n "$key" ] || { echo "No backup found under ${prefix}"; exit 1; }
echo "Latest backup: $key"

aws $aws_args s3 cp --quiet "${prefix}/${key}" /tmp/drill.dump.gpg
printf '%s' "$PASSPHRASE" | gpg --decrypt --batch --quiet --pinentry-mode loopback --passphrase-fd 0 /tmp/drill.dump.gpg > /tmp/drill.dump

dropdb $conn --if-exists "$scratch"
createdb $conn "$scratch"
pg_restore $conn -d "$scratch" --no-owner /tmp/drill.dump
psql $conn -d "$scratch" -tAc \
  "select count(*) || ' tables, ' || (select count(*) from users) || ' users' from information_schema.tables where table_schema = 'public'"

echo "Restore drill passed."
