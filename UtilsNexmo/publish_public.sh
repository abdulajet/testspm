
#upload to cocoapods
echo "pod trunk push NexmoClient.podspec"

pod trunk push NexmoClient.podspec

#create git tag
INFO_PLIST_FILE="$PWD/../NexmoClient/Info.plist"
SDK_VERSION=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" $INFO_PLIST_FILE)
MAJOR_VERSION=$(echo $SDK_VERSION | cut -d. -f1)
MINOR_VERSION=$(echo $SDK_VERSION | cut -d. -f2)
PATCH_VERSION=$(echo $SDK_VERSION | cut -d. -f3)

TAG_NAME="public/${MAJOR_VERSION}.${MINOR_VERSION}.${PATCH_VERSION}/v$SDK_VERSION"

echo "Marking the repo with tag $TAG_NAME"
git tag $TAG_NAME
git push origin $TAG_NAME

git branch develop
git checkout develop
git pull

let NEW_PATCH_VERSION=$PATCH_VERSION+1

NEW_FINAL_VERSION="$MAJOR_VERSION.$MINOR_VERSION.$NEW_PATCH_VERSION"
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $NEW_FINAL_VERSION" $INFO_PLIST_FILE

git add .
git commit -m "[NO-VAR] - update to next patch version: $NEW_PATCH_VERSION"
git push
