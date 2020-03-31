echo "Executing post clone script"

pip install awscli

aws s3 cp s3://nexmo-sdk-ci/iOS-SDK/SDK-release-internal/build-id/${APPCENTER_BUILD_ID}.env ./config.env

cat ./config.env

source ./config.env