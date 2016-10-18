#!/bin/sh
mix run --no-start -e 'IO.puts Mix.Project.config[:version]'

export VERSION=$(mix run --no-start -e 'IO.puts Mix.Project.config[:version]')
export MIX_ENV=prod
export PORT=4090
export LC_ALL=en_US.UTF-8
export PATH=/usr/bin

echo "=> BUILDING TUESDAY [$VERSION]"

echo "=> mix phoenix.digest"  &&
mix phoenix.digest            &&
echo "=> mix release"         &&
mix release --env=prod        &&

echo "=> Extracting release [$VERSION]" &&
sudo -u owncloud /usr/bin/tar zxf \
    rel/tuesday/releases/$VERSION/tuesday.tar.gz \
        -C /app/tuesday &&

echo "=> Restarting service..." &&
sudo systemctl restart ex-tuesday.service &&
echo "Done."
