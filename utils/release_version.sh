FILE=./StitchObjC.podspec

#create a new git tag for this version
echo "Creating a git tag"
VERSION=`cat $FILE  | ggrep  s.version| ggrep -oP '(?<=").*?(?=")'`
IFS='. ' read -a array <<< "$VERSION"
TAG_NAME="${array[0]}.${array[1]}/v$VERSION"
git tag $TAG_NAME
git push origin $TAG_NAME

#config the spec file with the tag
OLD_TAG=`cat $FILE | ggrep  ':tag =>'| ggrep -oP '(?<=:tag => ").*?(?=")'`
gsed -i.bak "s@$OLD_TAG@$TAG_NAME@" $FILE


#create a private pod specs repo localy (if not already created)
REPO_NAME=PrivatePods
QUERY_RES=`pod repo list | grep $REPO_NAME | head -n 1`
if [ "$REPO_NAME" != "$QUERY_RES" ]; then
    pod repo add PrivatePods git@github.com:Vonage/PrivateCocoapodsSpecs.git
fi

REPO_NAME=VonageNexmo
QUERY_RES=`pod repo list | grep $REPO_NAME | head -n 1`
if [ "$REPO_NAME" != "$QUERY_RES" ]; then
    pod repo add VonageNexmo git@github.com:Vonage/NexmoCocoaPodSpecs.git
fi

#upload the new spec
echo "Uploading the version"
pod repo push PrivatePods $FILE --allow-warnings --verbose --use-libraries

if [ $? -ne 0 ]
then
    echo "failed pushing new version to pods! Aborting"
    exit -1
fi
