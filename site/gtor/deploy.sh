#!/usr/bin/env bash
# Constants
PREFIX="gen-hippo"
SOURCE_FOLDER="../${PREFIX}"
JEKYLL_SOURCE="../../md-docs"
JEKYLL_DESTINATION="../../tmp"

# Markdown files to
INSTALLATION="../../tmp/ready/installation"
DEVELOP="../../tmp/ready/guides"
TRAINING="../../tmp/ready/training"

COMMAND_NAME="${PREFIX}"
COMMAND="./${COMMAND_NAME}"

# Variables
TODAY=`date "+%Y-%m-%d"`
SEQ=`date "+%H%M%S"`
STAMP="${TODAY}-${SEQ}"
INGEST_ID="${PREFIX}-${STAMP}"
INGEST_FOLDER="../${INGEST_ID}"
FILE_PATH="../${INGEST_ID}.zip"

# Build
if [[ ${1} = "build" ]]; then
	echo "Building..."
	rm -rf ${SOURCE_FOLDER}
	${COMMAND}
	echo "Building Jekyll..."
	jekyll build --source "${JEKYLL_SOURCE}" --destination "${JEKYLL_DESTINATION}"
	cp -rf ${OPENID} "${SOURCE_FOLDER}"
	cp -rf ${INSTALLATION} "${SOURCE_FOLDER}"
	cp -rf ${DEVELOP} "${SOURCE_FOLDER}/develop"
	cp -rf ${TRAINING} "${SOURCE_FOLDER}/develop"
	echo "Building Swagger..."
	cd ./../../swagger
	gulp build
	cd bootprint-openapi/examples
	node example.js
	cd ./../../../site/gtor/
fi

if [[ ${2} = "push" ]]; then
	echo "Pushing..."
else
	echo "Skipping push."
	exit 0
fi

# Rename folder
if [[ -e "${SOURCE_FOLDER}" ]]; then
	mv "${SOURCE_FOLDER}" "${INGEST_FOLDER}"
fi

if [[ "$?" -ne 0 ]]; then
	echo "mv failed with code $?"
	exit "$?"
fi

# Compress the ingest HTML
#find "${INGEST_FOLDER}" -path '*/.*' -prune -o -type f -print | zip "${FILE_PATH}" -@
ditto -c -k --sequesterRsrc --keepParent "${INGEST_FOLDER}" "${FILE_PATH}"

if [[ "$?" -ne 0 ]]; then
	echo "zip failed with code $?"
	exit "$?"
fi

if [[ -e "push.sh" ]]; then
	rm push.sh
fi

if [[ "$?" -ne 0 ]]; then
	echo "rm push.sh failed with code $?"
	exit "$?"
fi

# Build the SFTP command input script
echo "
cd uploads/mobile
put ${FILE_PATH}
" > push.sh

if [[ "$?" -ne 0 ]]; then
	echo "create push.sh failed with code $?"
	exit "$?"
fi

# Upload using the command input script
sftp -b push.sh -oIdentityFile=~/.ssh/cb_xfer_id_rsa cb_xfer@54.175.181.113

if [[ "$?" -ne 0 ]]; then
	echo "sftp failed with code $?"
	exit "$?"
fi

if [[ -e "push.sh" ]]; then
	rm push.sh
fi

# Trigger the AuthX Jenkins job to ingest the docset and update the 
# staging environment at http://developer-stage.cbauthx.com/documentation/
if [[ ${3} = "stage" ]]; then
#	curl http://build-ingestion.cbauthx.com/job/CouchbaseDocumentationJobs/job/Mobile/job/IngestStage/build\?delay\=0sec
fi

if [[ ${3} = "qa" ]]; then
#	curl http://build-ingestion.cbauthx.com/job/CouchbaseDocumentationJobs/job/Mobile/job/IngestQA/build\?delay\=0sec
fi

if [[ "$?" -ne 0 ]]; then
	echo "curl failed with code $?"
	exit "$?"
fi

# NOTE: we can also do (later) param substitution via the curl command
#       using query params in this form: 
#              "http://JENKINS_HOST/job/MY_JOB_NAME/buildWithParameters?PARAMETER0=VALUE0&PARAMETER1=VALUE1"

exit 0
