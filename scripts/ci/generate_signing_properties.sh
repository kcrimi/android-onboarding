#!/usr/bin/env bash
# Build the signing.properties from the .keystore and its auth credentials stored on CircleCI
# as ENV variables

SIGNING_PROPERTIES_FILE="signing.properties"
echo "STORE_FILE=../assets/deploy/skillshare.keystore" > $SIGNING_PROPERTIES_FILE
echo "STORE_PASSWORD=$SIGNING_STORE_PASSWORD" >> $SIGNING_PROPERTIES_FILE
echo "KEY_ALIAS=$SIGNING_KEY_ALIAS" >> $SIGNING_PROPERTIES_FILE
echo "KEY_PASSWORD=$SIGNING_KEY_PASSWORD" >> $SIGNING_PROPERTIES_FILE
