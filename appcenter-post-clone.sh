echo "Executing post clone script"

pip install awscli

S3_BUCKET=nexmo-sdk-ci
S3_VARS_ENV=iOS-SDK/SDK-release-internal/branches/${APPCENTER_BRANCH}/build-id/${APPCENTER_BUILD_ID}/vars.env

poll_s3() {
    while true; do
        exists=$(aws s3api head-object --bucket $1 --key $2 || true)
        if [ -z "$exists" ]; then
            echo "file not exist yet"
            sleep 5
        else
            echo "file exists"
            break
        fi
    done
}

poll_s3 $S3_BUCKET $S3_VARS_ENV
aws s3 cp s3://$S3_BUCKET/$S3_VARS_ENV ./vars.env

cat ./vars.env

source ./vars.env