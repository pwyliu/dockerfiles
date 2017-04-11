#!/bin/bash
# Uploads files to S3 using SSE-C.
# Requires the following environment variables:
# 
# AWS_ACCESS_KEY_ID     - IAM access key
# AWS_SECRET_ACCESS_KEY - IAM secret key
# AWS_S3_ENCRYPTION_KEY - customer provided encryption key
# AWS_S3_BUCKET         - the destination bucket
#
# Forked from https://gist.github.com/imbradbrown/df9e75e1202efacf70f0
set -euo pipefail

# Generic functions
function log () {
  printf "$(date) $*\n"
}

function die () {
  log "ERROR: $*"
  exit 2
}

function usage_and_exit () {
  echo "Usage: s3-sse-upload.sh -f SOURCE -d S3_PATH -b S3_BUCKET"
  exit 2
}

# Helpers

function encode_keys () {
# 
}

# Handle args
while getopts "f:d:b:" OPTION
do
  case ${OPTION} in
    f) source_path=$OPTARG;;
    c) dest_path=$OPTARG;;
    b) dest_bucket=$OPTARG;;
    *) usage_and_exit;;
  esac
done

# bail if no source or destination specified
if [[ -z ${source_file} ]] || [[ -z ${dest_file} ]] || [[ -z ${} ]]; then
  usage_and_exit
fi

S3_UPLOAD_FILE=some/path/file.txt
S3_BUCKET=bucket name here
S3_DESTINATION_FILE=folder/folder2/file.txt

S3_KEY=Amazon Admin Access Key
S3_SECRET= Secret Key Here

S3_CONTENT_TYPE="application/octet-stream"

## The date formatted in GMT
S3_DATE="$(LC_ALL=C date -u +"%a, %d %b %Y %X %z")"

S3_MD5SUM="$(openssl md5 -binary < ${S3_UPLOAD_FILE} | base64)"

S3_SSEC_ALGORITHM=AES256

## The Server Side Encryption - Customer Provided Key to use. This must be 32 bytes in length
S3_SSEC_KEY=00000000000000000000000000012345

## Base64 encode the SSE-C key. This is used as the x-amz-server-side-encryption-customer-key
S3_ENCRYPTION_KEY="$(echo -n ${S3_SSEC_KEY} | openssl enc -base64)"

## MD5 hash the SSE-C key. Base64 the result. This is used as the x-amz-server-side-encryption-customer-key-MD5
S3_ENCRYPTION_MD5="$(echo -n ${S3_SSEC_KEY} | openssl dgst -md5 -binary | openssl enc -base64)"

## S3 validates the request by checking the data passed in is in a specific order. See http://docs.aws.amazon.com/AmazonS3/latest/API/sigv4-authentication-HTTPPOST.html
S3_SIGNATURE="$(printf "PUT\n$S3_MD5SUM\n$S3_CONTENT_TYPE\n$S3_DATE\nx-amz-server-side-encryption-customer-algorithm:$S3_SSEC_ALGORITHM\nx-amz-server-side-encryption-customer-key:$S3_ENCRYPTION_KEY\nx-amz-server-side-encryption-customer-key-md5:$S3_ENCRYPTION_MD5\n/$S3_BUCKET/$S3_DESTINATION_FILE" | openssl sha1 -binary -hmac "$S3_SECRET" | base64)"

## Send the actual curl
curl -v -T ${S3_UPLOAD_FILE} https://$S3_BUCKET.s3.amazonaws.com/${S3_DESTINATION_FILE} \
     -H "Date: ${S3_DATE}" \
     -H "Authorization: AWS ${S3_KEY}:${S3_SIGNATURE}" \
     -H "Content-Type: ${S3_CONTENT_TYPE}" \
     -H "Content-MD5: ${S3_MD5SUM}" \
     -H "x-amz-server-side-encryption-customer-algorithm:${S3_SSEC_ALGORITHM}" \
     -H "x-amz-server-side-encryption-customer-key:${S3_ENCRYPTION_KEY}" \
     -H "x-amz-server-side-encryption-customer-key-MD5:${S3_ENCRYPTION_MD5}"

