#!/usr/bin/env bash

##
# Update port in nginx config
#
# sed -i "s/80/$PORT/g" /etc/nginx/sites-available/default

##
# Run a command or start supervisord
#
if [ $# -gt 0 ];then
    # If we passed a command, run it
    exec "$@"
else
    # Otherwise start supervisord
    /usr/bin/supervisord
fi
