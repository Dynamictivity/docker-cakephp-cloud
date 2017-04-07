#!/usr/bin/env bash

# Clear vendors (composer)
#rm -rf /www/vendor

# Clone the app source code
if [ -n "$REPO" ] ; then
    ssh-keyscan -H $REPO_HOST >> ~/.ssh/known_hosts
    git clone $REPO /source
    cd /source && git pull origin master
fi

if [ -d "/source" ]; then
    rsync -vaz /source/* /www
fi

# Install app dependencies
composer install --working-dir=/www

# Copy over app configuration
cp /app.php /www/config/app.php

# Wait for MySQL to come up (http://stackoverflow.com/questions/6118948/bash-loop-ping-successful)
((count = 100000))                            # Maximum number to try.
while [[ $count -ne 0 ]] ; do
    nc -v $DB_HOST 3306                      # Try once.
    rc=$?
    if [[ $rc -eq 0 ]] ; then
        ((count = 1))                      # If okay, flag to exit loop.
    fi
    ((count = count - 1))                  # So we don't go forever.
done

if [[ $rc -eq 0 ]] ; then                  # Make final determination.
    echo 'The MySQL server is up.'
else
    echo 'Timeout waiting for MySQL server.'
fi

# Run db migrations
cd /www; bin/cake migrations migrate

# Seed the db
if [ -n "$DB_SEED" ] ; then
    cd /www; bin/cake migrations seed --seed $DB_SEED || true
fi

chmod 777 /www/logs

# Start php-fpm
nohup /usr/sbin/php-fpm7.0 &