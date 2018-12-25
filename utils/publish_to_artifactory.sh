#!/bin/bash

. script_include.sh

if [ "$ARTIFACTORY_USER" == "" ]; then
	echo_red "ARTIFACTORY_USER env variable is not set. Aborting."
	exit 1
fi

if [ "$ARTIFACTORY_PASSWORD" == "" ]; then
	echo_red "ARTIFACTORY_PASSWORD env variable is not set. Aborting."
	exit 1
fi

INFO_PLIST_FILE="$PWD/../NexmoClient/Info.plist"

PLIST_VERSION=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" $INFO_PLIST_FILE)

ARTIFACTORY_PATH_DEBUG=$(get_artifactory_artifact_path "Debug" $PLIST_VERSION)
ARTIFACTORY_PATH_RELEASE=$(get_artifactory_artifact_path "Release" $PLIST_VERSION)

if [ $? -ne 0 ]; then
	exit 1
fi

pushd $PWD/../Output/Debug
zip --symlinks -r -9 NexmoClient.zip NexmoClient.framework
curl -f -u "$ARTIFACTORY_USER:$ARTIFACTORY_PASSWORD" -X PUT "$ARTIFACTORY_PATH_DEBUG" -T NexmoClient.zip

if [ $? -ne 0 ]; then
	echo_red "upload failed. Aborting"
	exit 1
fi

popd

pushd $PWD/../Output/Release
zip --symlinks -r -9 NexmoClient.zip NexmoClient.framework
curl -f -u "$ARTIFACTORY_USER:$ARTIFACTORY_PASSWORD" -X PUT "$ARTIFACTORY_PATH_RELEASE" -T NexmoClient.zip

if [ $? -ne 0 ]; then
	echo_red "upload failed. Aborting"
	exit 1
fi

popd

echo_green "Done deployment to artifactory."