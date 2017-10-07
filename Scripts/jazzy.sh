#!/bin/sh

bundle install

bundle exec jazzy \
  --module SymondsStudentApp \
  --min-acl private \
  --theme apple \
  --github_url "https://www.github.com/geosor/SymondsStudentApp" \
  --author "Søren Mortensen, George Taylor"