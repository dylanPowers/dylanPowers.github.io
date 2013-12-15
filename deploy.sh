#!/bin/sh


echo "Running pub build..."

pub build
if [$? -ne 0]; then
  echo "Pub build failed"
  exit 1
fi


echo "Attempting to commit to master..."

build_rev_hash=`git rev-parse HEAD`
build_rev_branch=`git rev-parse --abbrev-ref HEAD`
