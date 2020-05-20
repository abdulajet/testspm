#!/bin/bash

. script_include.sh

# if [ "$ARTIFACTORY_USER" == "" ]; then
# 	echo_red "ARTIFACTORY_USER env variable is not set. Aborting."
# 	exit 1
# fi

# if [ "$ARTIFACTORY_PASSWORD" == "" ]; then
# 	echo_red "ARTIFACTORY_PASSWORD env variable is not set. Aborting."
# 	exit 1
# fi

if [ "$BUILD_NUMBER" == "" ]; then
	echo_red "BUILD_NUMBER env variable is not set. Aborting. Please Run from Jenkins job."
	exit 1
fi

INFO_PLIST_FILE="$PWD/../NexmoClient/Info.plist"

PLIST_VERSION=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" $INFO_PLIST_FILE)

FINAL_VERSION="$PLIST_VERSION.$BUILD_NUMBER"

# ARTIFACTORY_PATH_DEBUG=$(get_artifactory_artifact_path "Debug" $FINAL_VERSION)
# ARTIFACTORY_PATH_RELEASE=$(get_artifactory_artifact_path "Release" $FINAL_VERSION)
CHANGELOG_FILE=CHANGELOG.md

if [ $? -ne 0 ]; then
	exit 1
fi

./create_docs.sh $FINAL_VERSION

pushd $PWD/../Output/Debug
cp -R ../../LICENSE ../../Utils/README.md ../../docs .
zip --symlinks -r -9 NexmoClient.zip NexmoClient.framework LICENSE README.md docs
rm -rf LICENSE README.md docs

# curl -f -u "$ARTIFACTORY_USER:$ARTIFACTORY_PASSWORD" -X PUT "$ARTIFACTORY_PATH_DEBUG" -T NexmoClient.zip
CONFIGURATION="Debug"
sftp -i $S3_PRIVATE_KEY_FILE nexmo-sdk-ci@s-15a7bf753d804d299.server.transfer.eu-west-1.amazonaws.com << EOF
put NexmoClient.zip /nexmo-conversation/iOS-SDK/SDK-release-internal/${FINAL_VERSION}/NexmoClient-${FINAL_VERSION}-iOS-${CONFIGURATION}.zip
EOF

if [ $? -ne 0 ]; then
	echo_red "upload failed. Aborting"
	exit 1
fi

popd

pushd $PWD/../Output/Release

cp -R ../../LICENSE ../../Utils/README.md ../../docs .
zip --symlinks -r -9 NexmoClient.zip NexmoClient.framework LICENSE README.md docs
rm -rf LICENSE README.md docs

# curl -f -u "$ARTIFACTORY_USER:$ARTIFACTORY_PASSWORD" -X PUT "$ARTIFACTORY_PATH_RELEASE" -T NexmoClient.zip
CONFIGURATION="Release"
sftp -i $S3_PRIVATE_KEY_FILE nexmo-sdk-ci@s-15a7bf753d804d299.server.transfer.eu-west-1.amazonaws.com << EOF
put NexmoClient.zip /nexmo-conversation/nexmo-sdk-ci/iOS-SDK/SDK-release-internal/${FINAL_VERSION}/NexmoClient-${FINAL_VERSION}-iOS-${CONFIGURATION}.zip
EOF

if [ $? -ne 0 ]; then
	echo_red "upload failed. Aborting"
	exit 1
fi

popd

# echo_green "Done deployment to artifactory."
echo_green "Done deployment to AWS S3."
