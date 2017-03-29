#!/bin/bash
ORG=mxcl
REPO=PromiseKit
TAG=4.1.8

ORG=$(echo $1 | cut -f1 -d/)
REPO=$(echo $1 | cut -f2 -d/)
ARCHIVES=${2//,/ }
TAG=$3

rm -rf Checkout
rm -rf Archives

if [ -z $ORG ]; then
  echo "Missing org. Usage: ./build.sh <org>/<repo> <frameworks,to,archive> [tag]";
  exit
fi

if [ -z $REPO ]; then
  echo "Missing repo. Usage: ./build.sh <org>/<repo> <frameworks,to,archive> [tag]";
  exit
fi

if [ -z $2 ]; then
  echo "Archives not specified, using the repo name for carthage archive";
  ARCHIVES=$REPO
fi

mkdir Checkout
mkdir Archives

cd Checkout
git clone https://github.com/$ORG/$REPO || exit 1
cd $REPO

if [ -z $TAG ]; then
  if [ -z $TRAVIS_TAG ]; then
    echo "No tag found: building for master";
    TAG="master"
  else
    TAG=$TRAVIS_TAG
    echo "Building TRAVIS_TAG: $TAG";
  fi
else
  echo "Building tag: $TAG";
fi

git checkout $TAG || { echo "The tag for this repo must match the tag of the mirrored repo."; exit 1; }

if [ -f Cartfile ]; then
    if [ ! -f Cartfile.resolved ]; then
        echo "Cartfile present but not Cartfile.resolved, running carthage bootstrap to resolve"
        carthage bootstrap --platform iOS || exit 1
    fi
fi

carthage build --no-skip-current --platform iOS || exit 1
echo "Running carthage archive for: $ARCHIVES"
carthage archive $ARCHIVES || exit 1
mv *.framework.zip ../../Archives
