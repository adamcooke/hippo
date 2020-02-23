#!/bin/bash

set -e
rm -rf .vuepress/dist
yarn docs:build
cd .vuepress/dist
git init
git add .
git commit -m "deployment"
git push -f git@github.com:adamcooke/hippo master:gh-pages
cd -
