#!/bin/bash

FILE=../stitchObjc.podspec

VERSION=`cat $FILE  | ggrep  s.version| ggrep -oP '(?<=").*?(?=")'`
IFS='/ ' read -a array <<< "$2"
FEATURE_NAME="${array[2]}"
NEW_VERSION="0.$1-$FEATURE_NAME"

echo "Feature branch version $NEW_VERSION"

gsed -i.bak "/.*s.version/s/$VERSION/$NEW_VERSION/" $FILE



echo $NEW_VERSION
