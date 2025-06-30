#!/bin/bash

function check_env_creds() {
	echo "Current AWS Profile"
	aws sts get-caller-identity
}

function setenv () {

	check_env_creds

	echo "setting the following environment variables... $1, $2"
	export CLUSTER_NAME="$1"
	export CLUSTER_REGION="$2"
	export AWS_PROFILE=DevOpsAdmin
	
	echo "region is set to $CLUSTER_REGION"
	echo "cluster to be deployed $CLUSTER_NAME"
	echo "Aws Profile set to $AWS_PROFILE"
	echo "Current Caller identity"
	aws sts get-caller-identity
	echo "/ ------------- END ENV VARS CHECK -----/"
}

setenv "$1" "$2"



