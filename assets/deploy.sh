#!/bin/sh
source /usr/share/nvm/init-nvm.sh

mix run --no-start -e 'IO.puts Mix.Project.config[:version]'

export VERSION=$(mix run --no-start -e 'IO.puts Mix.Project.config[:version]')
export MIX_ENV=prod
export PORT=4090
export LC_ALL=en_US.UTF-8
# export PATH=/usr/local/bin:/usr/bin:/bin

echo "=> BUILDING TUESDAY [$VERSION]"

echo "=> building assets"  &&
rm -rf priv/static/*
cd assets
# brunch b -p
./node_modules/brunch/bin/brunch b -p
cd ..
echo "=> mix phx.digest"  &&
mix phx.digest            &&
echo "=> mix release"     &&
mix release --env=prod    &&

echo "=> Extracting release [$VERSION]" &&
sudo -u http /usr/bin/tar zxf \
    _build/prod/rel/tuesday/releases/$VERSION/tuesday.tar.gz \
        -C /app/tuesday &&

echo "=> Restarting service..." &&
sudo systemctl restart ex-tuesday.service &&
echo "Done."
