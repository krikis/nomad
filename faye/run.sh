#!/usr/bin/env bash
# BASEDIR=$(dirname $0)
# BUNDLE_GEMFILE=$BASEDIR/Gemfile
# echo "bundle exec rackup $BASEDIR/config.ru -s thin -E production"
cd faye
bundle exec rackup config.ru -s thin -E production
