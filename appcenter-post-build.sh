echo "Executing post build script"

source ./vars.env


# build iOS SDK

export BUILD_NUMBER=$APPCENTER_BUILD_ID
echo "BUILD_NUMBER = $BUILD_NUMBER"

make release_internal_nexmo


# generate docs

INFO_PLIST_FILE="NexmoClient/Info.plist"
PUBLIC_VERSION=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" $INFO_PLIST_FILE)
PRIVATE_VERSION="${PUBLIC_VERSION}.${BUILD_NUMBER}"
COPYRIGHT_YEAR=$(eval date +"%Y")

sed -e "s^###SDK_PUBLIC_VERSION###^$PUBLIC_VERSION^g" \
    -e "s^###COPYRIGHT_YEAR###^$COPYRIGHT_YEAR^g" \
    Utils/README_md.template > Utils/README.md

sudo gem install jazzy

jazzy --objc --author Vonage \
    --author_url https://developer.nexmo.com \
    --module-version $PUBLIC_VERSION \
    --umbrella-header NexmoClient/NexmoClient.h \
    --framework-root . \
    --module NexmoClient \
    --output docs \
    --readme Utils/README.md

(cd ./docs; zip -rX docs.zip *)

aws s3 cp ./docs/docs.zip s3://nexmo-sdk-ci/iOS-SDK/SDK-release-external/branches/${APPCENTER_BRANCH}/conversation-docs/${PRIVATE_VERSION}.zip
