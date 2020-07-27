echo "Executing post build script"

SFTP_ADDR=nexmo-sdk-ci@s-15a7bf753d804d299.server.transfer.eu-west-1.amazonaws.com
S3_BUCKET=nexmo-conversation
S3_BUILD_DIR=nexmo-sdk-ci/iOS-SDK/SDK-release-internal/branches/${APPCENTER_BRANCH}/build-id/${APPCENTER_BUILD_ID}
S3_PRIVATE_KEY_FILE=$(mktemp)

echo $S3_PRIVATE_KEY | base64 -d > ${S3_PRIVATE_KEY_FILE}

poll_s3() {
    while true; do
	    exists=$(sftp -o StrictHostKeyChecking=no -i ${S3_PRIVATE_KEY_FILE} ${SFTP_ADDR}:/${S3_BUCKET}/${S3_BUILD_DIR}/vars.env || true) 
        if [ -z "$exists" ]; then
            echo "file not exist yet"
            sleep 5
        else
            echo "file exists"
            break
        fi
    done
}

poll_s3 
cat ./vars.env

source ./vars.env


# cd into root folder
cd ..


# build iOS SDK

export BUILD_NUMBER=$APPCENTER_BUILD_ID
echo "BUILD_NUMBER = $BUILD_NUMBER"

# git identity 
git config --global user.email "appcenter@nexmo.com"
git config --global user.name "Appcenter"

make release_internal


# generate docs

INFO_PLIST_FILE="NexmoClient/Info.plist"
PUBLIC_VERSION=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" $INFO_PLIST_FILE)
PRIVATE_VERSION="${PUBLIC_VERSION}.${BUILD_NUMBER}"
COPYRIGHT_YEAR=$(eval date +"%Y")

sed -e "s^###SDK_PUBLIC_VERSION###^$PUBLIC_VERSION^g" \
    -e "s^###COPYRIGHT_YEAR###^$COPYRIGHT_YEAR^g" \
    Utils/README_md.template > Utils/README.md

# IMPORTANT: jazzy docs generator doesn’t always support the latest Xcode versions
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

sftp -i $S3_PRIVATE_KEY_FILE $SFTP_ADDR << EOF
put ./docs/docs.zip ${S3_BUILD_DIR}/conversation-docs/${PRIVATE_VERSION}.zip
EOF


# uploading version.txt

echo $PRIVATE_VERSION >> version.txt

sftp -i $S3_PRIVATE_KEY_FILE $SFTP_ADDR << EOF
put ./version.txt ${S3_BUILD_DIR}/version.txt
EOF
