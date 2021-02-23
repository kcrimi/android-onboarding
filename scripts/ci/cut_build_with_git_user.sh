#!/usr/bin/env bash

# Assigns the git user for running git commands on CI

echo "Cutting a new build"
git config --global user.email "android@skillshare.com"
git config --global user.name "skillshare-android"
git config --global push.default current
bash ./scripts/cut_build.sh