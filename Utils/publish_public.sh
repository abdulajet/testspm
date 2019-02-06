
#upload to cocoapods
echo "pod trunk push NexmoClient.podspec"

pod trunk push NexmoClient.podspec

#create git tag
INFO_PLIST_FILE="$PWD/../NexmoClient/Info.plist"
SDK_VERSION=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" $INFO_PLIST_FILE)
MAJOR_VERSION=$(echo $PLIST_VERSION | cut -d. -f1)
MINOR_VERSION=$(echo $PLIST_VERSION | cut -d. -f2)

TAG_NAME="Public/${MAJOR_VERSION}.${MINOR_VERSION}/v$SDK_VERSION"
PR_BRANCH="release/iosdocs/${SDK_VERSION}"

echo "Marking the repo with tag $TAG_NAME"
git tag $TAG_NAME
git push origin $TAG_NAME

#upload docs to nexmo
# checkout conversation-docs project and create a new branch
pushd ../../
echo "git clone git@github.com:Nexmo/conversation-docs.git"
git clone git@github.com:Nexmo/conversation-docs.git
pushd conversation-docs

echo "checkout -b $PR_BRANCH"
git checkout -b $PR_BRANCH

# copy docs
echo "cp -R ../NexmoClient/docs ./ios/$SDK_VERSION"
cp -R ../nexmo-sdk-ios/docs ./ios/$SDK_VERSION

git add --all
echo "git commit -a -m \"update iosdocs for v${SDK_VERSION}\""
git commit -a -m "update iosdocs for v${SDK_VERSION}"

echo "git push origin $PR_BRANCH"
git push origin $PR_BRANCH

# open PR
echo "hub pull-request -m \"update iosdocs for v${SDK_VERSION}\" -r mobileSDK"
hub pull-request -m "update iosdocs for v${SDK_VERSION}"

popd
popd
