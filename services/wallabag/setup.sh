#!/bin/sh
set -euo pipefail

echo "--- Waiting for Database booooo---"
until pg_isready -h "$SYMFONY__ENV__DATABASE_HOST" -p "$SYMFONY__ENV__DATABASE_PORT" -U "$SYMFONY__ENV__DATABASE_USER"; do
  echo "Postgres unavailable - sleeping..."
  sleep 2
done

echo "--- Fixing Permissions ---"
chown -R nobody:nobody /var/www/wallabag

echo "--- Starting Wallabag in background ---"
/entrypoint.sh wallabag 2>&1 | tee /tmp/wallabag.log &
sleep 1 # Give it a moment to start and write logs

WALLABAG_PID=$!

echo "--- Waiting for Wallabag to be ready ---"
timeout 120 /bin/sh -c 'until grep -q "wallabag is ready!" /tmp/wallabag.log; do sleep 0.5; done'

echo "--- Wallabag initialized! Running migrations ---"
bin/console doctrine:migrations:migrate --env=prod --no-interaction

echo "--- Checking if user $WALLABAG_USER exists ---"
USER_EXISTS=$(bin/console wallabag:user:list --env=prod 2>/dev/null | grep "^ *$WALLABAG_USER " || true)

if [ -z "$USER_EXISTS" ]; then
    echo "--- Creating User: $WALLABAG_USER ---"
    bin/console fos:user:create "$WALLABAG_USER" "${WALLABAG_USER}@example.com" "$WALLABAG_PASSWORD" --env=prod
    bin/console fos:user:promote "$WALLABAG_USER" ROLE_SUPER_ADMIN --env=prod
else
    echo "--- User $WALLABAG_USER already exists, skipping. ---"
fi

echo "--- Setup complete, Wallabag running ---"
wait $WALLABAG_PID
