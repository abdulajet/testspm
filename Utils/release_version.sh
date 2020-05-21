
#!/bin/bash

. script_include.sh

INFO_PLIST_FILE="$PWD/../NexmoClient/Info.plist"

if [ "$BUILD_NUMBER" == "" ]; then
	echo_red "BUILD_NUMBER env variable is not set. Aborting. Please Run from Jenkins job."
	exit 1
fi

if [ "$PRIVATE_COCOAPODS_GITHUB_TOKEN" == "" ]; then
	echo_red "PRIVATE_COCOAPODS_GITHUB_TOKEN env variable is not set. Aborting."
	exit 1
fi

PLIST_VERSION=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" $INFO_PLIST_FILE)
MAJOR_VERSION=$(echo $PLIST_VERSION | cut -d. -f1)
MINOR_VERSION=$(echo $PLIST_VERSION | cut -d. -f2)
PATCH_VERSION=$(echo $PLIST_VERSION | cut -d. -f3)

FINAL_VERSION="$PLIST_VERSION.$BUILD_NUMBER"

# create a private pod specs repo localy (if not already created)
REPO_NAME=PrivatePods
QUERY_RES=`pod repo list | grep $REPO_NAME | head -n 1`
if [ "$REPO_NAME" != "$QUERY_RES" ]; then
	pod repo add PrivatePods https://$PRIVATE_COCOAPODS_GITHUB_TOKEN:x-oauth-basic@github.com/nexmoinc/PrivateCocoapodsSpecs
fi

CONFIGURATIONS=(Debug Release)
for CONFIG in ${CONFIGURATIONS[@]}; do

	ARTIFACTORY_PATH=$(get_cdn_artifact_path $CONFIG $FINAL_VERSION)

	if [ "$CONFIG" == "Debug" ]; then
		NAME_WITH_CONFIGURATION="NexmoClient_Debug"
	else
		NAME_WITH_CONFIGURATION="NexmoClient"
	fi

	sed -e "s^###NAME_WITH_CONFIGURATION###^$NAME_WITH_CONFIGURATION^g" \
	    -e "s^###ARTIFACTORY_TEMPLATE###^$ARTIFACTORY_PATH^g" \
	    -e "s^###VERSION###^$FINAL_VERSION^g" \
	    NexmoClient_podspec.template > $NAME_WITH_CONFIGURATION.podspec

    echo "Updating pods for $CONFIG"
	pod repo push PrivatePods $NAME_WITH_CONFIGURATION.podspec --allow-warnings --verbose --use-libraries

	if [ $? -ne 0 ]
	then
	    echo "failed pushing new version to pods! Aborting"
	    exit -1
	fi
done

echo_green "Creating a git tag"

TAG_NAME="internal/$FINAL_VERSION"

echo "Marking the repo with tag $TAG_NAME"
git tag $TAG_NAME
git push origin $TAG_NAME
