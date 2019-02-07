
#upload to cocoapods
echo "pod trunk push NexmoClient.podspec"

pod trunk push NexmoClient.podspec

#create git tag
INFO_PLIST_FILE="$PWD/../NexmoClient/Info.plist"
SDK_VERSION=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" $INFO_PLIST_FILE)
MAJOR_VERSION=$(echo $SDK_VERSION | cut -d. -f1)
MINOR_VERSION=$(echo $SDK_VERSION | cut -d. -f2)

TAG_NAME="public/${MAJOR_VERSION}.${MINOR_VERSION}/v$SDK_VERSION"

echo "Marking the repo with tag $TAG_NAME"
git tag $TAG_NAME
git push origin $TAG_NAME
