#!/usr/bin/env bash
# This script will update the app's graphql schema for apollo to be able to query.
#
# It takes in an optional parameter for which QA number to call but will default to production.
# NOTE: Access to QA networks (VPN or in-office) required to update from them
#
# Usage: ./scripts/update_apollo_schema.sh {QA_SERVER_NUMBER}

command -v apollo >/dev/null 2>&1 || { echo "Apollo CLI is required but it's not installed.  Aborting."; exit 1; }

if [[ ! -z $1 ]]; then
    SERVER="https://api-qa-$1.skillshare.com/api/graphql"
else
    SERVER="https://www.skillshare.com/api/graphql"
fi

apollo schema:download --endpoint=${SERVER} skillsharedata/src/main/graphql/schema.json