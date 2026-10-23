#!/bin/bash
set -e

if [ ! -f /var/www/html/vendor/autoload.php ]; then
    echo "==> Installation des dépendances Composer..."
    cd /var/www/html
    composer install --no-interaction --prefer-dist --no-progress --no-ansi
fi

if [ -n "$DATABASE_URL" ]; then
    initialized=$(psql "$DATABASE_URL" -X -tA -v ON_ERROR_STOP=1 \
        -c "SELECT to_regclass('public.users') IS NOT NULL")

    if [ "$initialized" != "t" ]; then
        echo "==> Initialisation de la base de données..."
        for sql_file in /opt/database/init/*.sql; do
            echo "  -> Exécution : $sql_file"
            psql "$DATABASE_URL" -X -v ON_ERROR_STOP=1 -f "$sql_file"
        done
        echo "==> Base de données prête."
    else
        echo "==> La base de données est déjà initialisée."
    fi
fi

exec apache2-foreground
