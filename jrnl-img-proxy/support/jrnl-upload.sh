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
  printf "$(date) $(basename -- "$0"): $*\n"
}

function usage_and_exit () {
  echo "Usage: s3-sse-upload.sh -f SOURCE -b S3_BUCKET -d S3_PATH"
  exit 2
}

# Parse args
while getopts "b:d:f:" OPTION
do
  case ${OPTION} in
    b) dest_bucket=$OPTARG;;
    d) dest_path=$OPTARG;;
    f) source_path=$OPTARG;;
    *) usage_and_exit;;
  esac
done

# Sanity checks
if ! [[ -r ${source_path:-} ]]; then
  log "ERROR: cannot read source file ${source_path}"
  exit 1
fi

for cmd in "curl openssl"
do
  if ! command -v ${cmd} >> /dev/null; then
    log "ERROR: ${cmd} not found on path"
    exit 1
  fi
done

# Globals
if [[ -z ${AWS_S3_SSEC_KEY:-} ]] || [[ -z ${AWS_ACCESS_KEY_ID:-} ]] || [[ -z ${AWS_SECRET_ACCESS_KEY:-} ]]; then
  log "ERROR: must set AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY and AWS_S3_SSEC_KEY environment variables."
  exit 1
else
  s3_access_key=${AWS_ACCESS_KEY_ID}
  s3_secret_key=${AWS_SECRET_ACCESS_KEY}
  s3_ssec_key="$(echo -n ${AWS_S3_SSEC_KEY} | openssl enc -base64)"
  s3_ssec_key_md5="$(echo -n ${AWS_S3_SSEC_KEY} | openssl dgst -md5 -binary | openssl enc -base64)"
fi

s3_endpoint="s3.amazonaws.com"
s3_cipher="AES256"
s3_content_type="application/octet-stream"
s3_timestamp="$(LC_ALL=C date -u +"%a, %d %b %Y %X %z")"
s3_file_md5="$(openssl md5 -binary < ${source_path} | base64)"

# S3 signature calculation
s3_signature=<<EOF
PUT
${s3_file_md5}
${s3_content_type}
${s3_timestamp}
x-amz-server-side-encryption-customer-algorithm:${s3_cipher}
x-amz-server-side-encryption-customer-key:${s3_ssec_key}
x-amz-server-side-encryption-customer-key-md5:${s3_ssec_key_md5}
/${dest_bucket}/${dest_path}
EOF
s3_signature=$(openssl sha1 -binary -hmac "${s3_secret_key}" | base64)

# Upload file
curl -v -T ${source_path} https://${dest_bucket}.${s3_endpoint}/${dest_path} \
     -H "Date: ${s3_timestamp}" \
     -H "Authorization: AWS ${s3_access_key}:${s3_signature}" \
     -H "Content-Type: ${s3_content_type}" \
     -H "Content-MD5: ${s3_file_md5}" \
     -H "x-amz-server-side-encryption-customer-algorithm:${s3_cipher}" \
     -H "x-amz-server-side-encryption-customer-key:${s3_ssec_key}" \
     -H "x-amz-server-side-encryption-customer-key-MD5:${s3_ssec_key_md5}"
