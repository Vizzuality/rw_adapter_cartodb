#!/bin/bash
set -e
ps -fea

if [ "$1" = 'run' ]; then
  bin/rails server --port 5000 --binding 0.0.0.0
elif [ "$1" = 'migrate' ]; then
  bundle exec rake db:create
  bundle exec rake db:migrate
else
    exec "$@"
fi
