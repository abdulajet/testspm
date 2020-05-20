echo "Executing post build script"

source ./vars.env


# cd into root folder
cd ..


# build iOS SDK

export BUILD_NUMBER=$APPCENTER_BUILD_ID
echo "BUILD_NUMBER = $BUILD_NUMBER"

make release_internal


# generate docs

INFO_PLIST_FILE="NexmoClient/Info.plist"
PUBLIC_VERSION=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" $INFO_PLIST_FILE)
PRIVATE_VERSION="${PUBLIC_VERSION}.${BUILD_NUMBER}"
COPYRIGHT_YEAR=$(eval date +"%Y")

sed -e "s^###SDK_PUBLIC_VERSION###^$PUBLIC_VERSION^g" \
    -e "s^###COPYRIGHT_YEAR###^$COPYRIGHT_YEAR^g" \
    Utils/README_md.template > Utils/README.md

# IMPORTANT: jazzy v0.13.3 DOESN'T SUPPORT Xcode >11.3.1
JAZZY_VERSION=0.13.3
JAZZY_XCODE_VERSION=11.3.1
sudo gem install jazzy -v $JAZZY_VERSION
XCODE_SELECT_PATH=$(xcode-select -p)
echo "Switching to Xcode $JAZZY_XCODE_VERSION to run Jazzy v$JAZZY_VERSION"
sudo xcode-select --switch /Applications/Xcode_$JAZZY_XCODE_VERSION.app/Contents/Developer
jazzy --objc --author Vonage \
    --author_url https://developer.nexmo.com \
    --module-version $PUBLIC_VERSION \
    --umbrella-header NexmoClient/NexmoClient.h \
    --framework-root . \
    --module NexmoClient \
    --output docs \
    --readme Utils/README.md
sudo xcode-select --switch $XCODE_SELECT_PATH
echo "Switched back to the initial Xcode path: $XCODE_SELECT_PATH"

(cd ./docs; zip -rX docs.zip *)


# uploading docs.zip

SFTP_URL="nexmo-sdk-ci@s-15a7bf753d804d299.server.transfer.eu-west-1.amazonaws.com"
SFTP_BASE_PATH="/nexmo-conversation/nexmo-sdk-ci/iOS-SDK/SDK-release-internal/branches/${APPCENTER_BRANCH}/build-id/${APPCENTER_BUILD_ID}"

sftp -i $S3_PRIVATE_KEY_FILE $SFTP_URL << EOF
put ./docs.zip $SFTP_BASE_PATH/conversation-docs/${PRIVATE_VERSION}.zip
EOF


# uploading version.txt

echo $PRIVATE_VERSION >> version.txt

sftp -i $S3_PRIVATE_KEY_FILE $SFTP_URL << EOF
put ./version.txt $SFTP_BASE_PATH/version.txt
EOF
