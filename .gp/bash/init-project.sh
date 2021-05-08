#!/bin/bash
#
# SPDX-License-Identifier: MIT
# Copyright © 2021 Apolo Pena
#
# init-gitpod.sh
# Description:
# Initial configuration for an existing phpmyadmin installation.


# Load shared deps
. .gp/bash/workspace-init-logger.sh
. .gp/bash/spinner.sh

# Migrate and seed 
msg="Migrating and Seeding the 'laravel' database"
log_silent "$msg" && start_spinner "$msg"
if php artisan migrate:fresh --seed; then
  stop_spinner 0 && log "SUCCESS: $msg"
else
  stop_spinner 1 && log -e "ERROR: $msg"
  exit 1
fi

# Install and Configure GraphQL
if [[ ! -f config/graphql.php ]]; then
  msg="Installing Laravel GraphQL API rebing/graphql-laravel via Composer"
  if composer require rebing/graphql-laravel; then
    stop_spinner 0 && log "SUCCESS: $msg"
    msg="Extracting GraphQL configuration file to config/graphql.php"
    if php artisan vendor:publish --provider="Rebing\GraphQL\GraphQLServiceProvider"; then
      stop_spinner 0 && log "SUCCESS: $msg"
    else
      stop_spinner 1 && log -e "ERROR: $msg" && exit 1
    fi # end extract rebing/graphql-laravel config
  else
    stop_spinner 1 && log -e "ERROR: $msg" && exit 1
  fi # end install rebing/graphql-laravel
else
  msg="Installing Laravel dependencies"
  composer install
fi

