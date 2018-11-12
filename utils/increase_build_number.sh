#!/bin/bash

FILE=./StitchCore.podspec

VERSION=`cat $FILE  | ggrep  s.version| ggrep -oP '(?<=").*?(?=")'`
NUM_OF_DOTS=`cat $FILE | ggrep  s.version| ggrep -oP '(?<=").*?(?=")' | ggrep -o "\."| wc -l`

if [ $NUM_OF_DOTS == 1 ];
then
    NEW_VERSION="$VERSION.$1"

elif [ $NUM_OF_DOTS == 2 ];
then
    IFS='. ' read -a array <<< "$VERSION"
    NEW_VERSION="${array[0]}.${array[1]}.$1"

else
    echo "ERROR: unable to parse version [ VERSION = $VERSION ]"
    exit 1
fi

gsed -i.bak "/.*s.version/s/$VERSION/$NEW_VERSION/" $FILE


#increase the version of stitch client
FILE_Client=../StitchClient.podspec
gsed -i.bak "/.*s.version/s/$VERSION/$NEW_VERSION/" $FILE_Client


echo $NEW_VERSION

echo $NEW_VERSION
