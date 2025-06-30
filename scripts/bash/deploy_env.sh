#!/bin/bash

install_awslbc() {
	set -euo pipefail

	CLUSTER_NAME="$1"
	CLUSTER_REGION="$2"
	attempts=0

	for i in {1..30}
	do
		cluster_status=$(check_cluster $CLUSTER_NAME)
		
		if [[ $cluster_status == "ACTIVE" ]]; then
	    	echo "EKS Cluster $CLUSTER_NAME is ready. Installing LoadBalancer controller..."
			CLUSTER_VPC=$(aws eks describe-cluster --name $CLUSTER_NAME --region $CLUSTER_REGION --query "cluster.resourcesVpcConfig.vpcId" --output text)

			helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
				--namespace kube-system \
				--set clusterName=$CLUSTER_NAME \
				--set serviceAccount.create=false \
				--set region=${CLUSTER_REGION} \
				--set vpcId=${CLUSTER_VPC} \
				--set serviceAccount.name=aws-load-balancer-controller
			exit 0	
	    fi
		((attempt++))
		echo "LoadBalancer installation waiting for cluster to be ready. Attempt $attempt"
		sleep 30	
	done
	echo "Failed to install loadbalancer controller after 900 seconds"
	exit 1
}

check_cluster() {
	aws eks describe-cluster --name "$CLUSTER_NAME" --query "cluster.status" --output text			
}

check_lbc(){
	loadBalancerName=$(kubectl get svc -A -l app.kubernetes.io/name=aws-load-balancer-controller)
	lb=$(aws elbv2 describe-load-balancers --names $loadBalancerName --query 'LoadBalancers[0].State.Code')
}

apply_terraform() {
	terraformroot="/opt/homebrew/var/infrastructure/environments/dev"
	TF_plan="EKS_$1_$(date "+%Y-%m-%d %H:%M:%S")"
	echo "name of plan file : $TF_plan"
	
	#changing directory 
	cd $terraformroot
	curdir=$(pwd)
	echo $curdir
	
	terraform plan -out="$TF_plan"
	echo "beginning deployment..."
	echo "Checking Caller Identity after plan:"
	aws sts get-caller-identity
	sleep 5
	terraform apply "$TF_plan"
}

run_deploy() {

	# get variables
	dev="/opt/homebrew/var/infrastructure/environments/dev/"
	clustername=$1
	clusterregion=$2
	environment=$3

	#swith to the folder of selected environment

	# Check credentials and env vars checkenv.sh
		source ./env_vars.sh "$clustername" "$clusterregion"
		echo "Environment variable cluster name: $CLUSTER_NAME"
		echo "Environment variable cluster region: $CLUSTER_REGION"

	#Create resources with terraform apply
		export TF_VAR_nameofcluster=$CLUSTER_NAME
		echo "calling identity at beginning of apply terraform : "
		aws sts get-caller-identity
		apply_terraform $CLUSTER_NAME

	# Check for active Load Balancer Controller	
	for i in {1..30}; do
		if [[ "$(check_lbc)" == "active" ]]; then							
			echo "LBC ready...proceed to check app deployment"
			break
		else
			echo "Waiting for LBC readiness..."
			sleep 30
	    fi
	done 	
	
	# Alert if app deployment didnot complete
	if [[ "$(check_lbc)" != "active" ]]; then
		echo -e "The load balancer contoller did not arrive at an active state.\nCurrent state is : $(check_lbc)"
		echo "Check to enure successful app deployment"
	fi			
		
}

run_deploy "Thutmose" "us-east-1"