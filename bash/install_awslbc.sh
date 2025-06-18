#!/bin/bash

function install_awsLBC(){
	CLUSTER_NAME="$1"
	CLUSTER_REGION="$2"
	
	CLUSTER_VPC=$(aws eks describe-cluster --name $CLUSTER_NAME --region $CLUSTER_REGION --query "cluster.resourcesVpcConfig.vpcId" --output text)

	helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
	    --namespace kube-system \
	    --set clusterName=$CLUSTER_NAME \
	    --set serviceAccount.create=false \
	    --set region=${CLUSTER_REGION} \
	    --set vpcId=${CLUSTER_VPC} \
	    --set serviceAccount.name=aws-load-balancer-controller
}