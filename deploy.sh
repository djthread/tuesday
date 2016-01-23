#!/bin/sh
VERSION=0.0.1
MIX_ENV=prod
PORT=4090

mix release.clean &&
mix phoenix.digest &&
mix release &&

sudo -u nobody tar zxf rel/tuesday/releases/$VERSION/tuesday.tar.gz -C /app/tuesday &&

sudo systemctl restart ex-tuesday.service
