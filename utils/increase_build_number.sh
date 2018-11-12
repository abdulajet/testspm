#!/bin/bash

FILE=./StitchCore.podspec

VERSION=`cat $FILE  | ggrep  s.version| ggrep -oP '(?<=").*?(?=")'`
NUM_OF_DOTS=`cat $FILE | ggrep  s.version| ggrep -oP '(?<=").*?(?=")' | ggrep -o "\."| wc -l`


NEW_VERSION="$VERSION.$1"


gsed -i.bak "/.*s.version/s/$VERSION/$NEW_VERSION/" $FILE


#increase the version of stitch client
FILE_Client=./StitchClient.podspec
gsed -i.bak "/.*s.version/s/$VERSION/$NEW_VERSION/" $FILE_Client

echo "NEW_VERSION" $NEW_VERSION
