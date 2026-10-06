#!/bin/bash

# Gather output values
rootdir="/opt/homebrew/var/deploy/infrastructure"
cluster_dir="$rootdir/environments/dev/compute/eks_cluster"
eks_rtng_dir="$rootdir/environments/dev/alb/eks-routing"

echo "gathering outputs for variables >>>"

clustername=$(terraform -chdir=$cluster_dir output -raw cluster_name | cut -d'=' -f2-)
alb_sec_group_id=$(terraform -chdir=$cluster_dir output -raw alb_sec_group_id | cut -d'=' -f2-)
target_group_arn=$(terraform -chdir=$eks_rtng_dir output -raw tgtgrp_arn | cut -d'=' -f2-)
#appversion=$(echo "$clustername" | cut -d'-' -f2-)
appversion="20260811_1158"

echo "cluster name: $clustername"
echo "security group Id: $alb_sec_group_id"
echo "target group arn: $target_group_arn"
echo "app version: $appversion"

# set variables

env="dev"
region="us-east-1"
image_repository="488347380548.dkr.ecr.us-east-1.amazonaws.com/dev/gemapp"
helm_release_name="gemapp"
projectname="gemapp"
helm_chart_path="$rootdir/helm-charts/gem-app/dev/ephmrl"
helm_namespace="ns-gemapp"
aws_default_region="us-east-1"
aws_region="us-east-1"

# Update kube config and run preflight check

 aws eks update-kubeconfig --name $clustername --region $region

echo "=== Helm template dry-run — checking for manifest errors ==="
          helm template "$helm_release_name" "$helm_chart_path" \
            --namespace $helm_namespace \
            --values $helm_chart_path/values.yaml \
            --set image.repository=$image_repository \
            --set image.tag=$appversion \
            --set environment=$env \
            --set targetGroupBinding.targetGroupArn=$target_group_arn \
            --set albSecurityGroupId=$alb_sec_group_id \
            --set containerPort=8000 \
            --debug 2>&1 | tee /tmp/helm-template-output.txt

# deploy app
 helm upgrade --install $helm_release_name $helm_chart_path \
            --namespace $helm_namespace --create-namespace \
            --values $helm_chart_path/values.yaml \
            --set image.repository=$image_repository \
            --set app.name=$helm_release_name \
            --set image.tag=$appversion \
            --set environment=$env \
            --set targetGroupBinding.targetGroupArn=$target_group_arn \
            --set albSecurityGroupId=$alb_sec_group_id \
            --set containerPort=8000 \
            --timeout 10m \
            --wait \
            --debug || {
              echo "=== Helm deployment failed — dumping pod logs ==="
              kubectl describe pods -n $helm_namespace -l app=$helm_release_name
              kubectl logs -n $helm_namespace -l app=$helm_release_name --previous 2>/dev/null || true
              exit 1
            }