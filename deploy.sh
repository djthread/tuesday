#!/bin/sh
export VERSION=$(mix run -e 'IO.puts Mix.Project.config[:version]')
export MIX_ENV=prod
export PORT=4090
export LC_ALL=en_US.UTF-8

# mix release.clean  &&
mix deps.get       &&
mix deps.compile   &&
mix phoenix.digest &&
mix release        &&

sudo "Extracting release . . ." &&
sudo -u nobody tar zxf rel/tuesday/releases/$VERSION/tuesday.tar.gz -C /app/tuesday &&

echo "Upgrading . . ." &&
sudo -u nobody /app/tuesday/bin/tuesday upgrade "$VERSION"

# sudo systemctl restart ex-tuesday.service
