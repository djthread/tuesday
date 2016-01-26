#!/bin/sh
export VERSION=0.0.1
export MIX_ENV=prod
export PORT=4090

mix release.clean  &&
mix deps.get       &&
mix deps.compile   &&
mix phoenix.digest &&
mix release        &&

sudo -u nobody tar zxf rel/tuesday/releases/$VERSION/tuesday.tar.gz -C /app/tuesday &&

sudo systemctl restart ex-tuesday.service
