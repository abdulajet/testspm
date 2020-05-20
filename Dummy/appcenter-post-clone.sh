echo "Executing post clone script"

SFTP_ADDR=nexmo-sdk-ci@s-15a7bf753d804d299.server.transfer.eu-west-1.amazonaws.com
S3_BUCKET=nexmo-conversation
S3_VARS_ENV=nexmo-sdk-ci/iOS-SDK/SDK-release-internal/branches/${APPCENTER_BRANCH}/build-id/${APPCENTER_BUILD_ID}/vars.env
export S3_PRIVATE_KEY_FILE="$(mktemp)"

echo $S3_PRIVATE_KEY | base64 -d > ${S3_PRIVATE_KEY_FILE}

poll_s3() {
    while true; do
	    exists=$(sftp -o StrictHostKeyChecking=no -i ${S3_PRIVATE_KEY_FILE} ${SFTP_ADDR}:/${S3_BUCKET}/${S3_VARS_ENV} || true) 
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