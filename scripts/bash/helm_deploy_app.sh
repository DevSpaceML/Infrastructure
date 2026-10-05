#!/bin/bash

# set variables
rootdir="/opt/homebrew/var/deploy/infrastructure"
env="dev"
region="us-east-1"
clustername="gemapp-1004-2010"
region="us-east-1"
image_repository="488347380548.dkr.ecr.us-east-1.amazonaws.com/dev/gemapp"
helm_release_name="gemapp"
projectname="gemapp"
helm_chart_path="$rootdir/helm-charts/gem-app/dev/ephmrl"
helm_namespace="ns-gemapp"
target_group_arn="arn:aws:elasticloadbalancing:us-east-1:488347380548:targetgroup/tg-gemapp/2f754db324abdbf2"
app_version="20260811_1158"
aws_default_region="us-east-1"
aws_region="us-east-1"

# Update kube config and run preflight check
aws eks update-kubeconfig --name $clustername --region $region

echo "=== Helm template dry-run — checking for manifest errors ==="
          helm template "$helm_release_name" "$helm_chart_path" \
            --namespace $helm_namespace \
            --values $helm_chart_path/values.yaml \
            --set image.repository=$image_repository \
            --set image.tag=$app_version \
            --set environment=$env \
            --set targetGroupBinding.targetGroupArn=$target_group_arn \
            --set albSecurityGroupId="sg-0823491d25edecd1d" \
            --debug 2>&1 | tee /tmp/helm-template-output.txt

 deploy app
 helm upgrade --install $helm_release_name $helm_chart_path \
            --namespace $helm_namespace --create-namespace \
            --values $helm_chart_path/values.yaml \
            --set image.repository=$image_repository \
            --set app.name=$helm_release_name \
            --set image.tag=$app_version \
            --set environment=$env \
            --set targetGroupBinding.targetGroupArn=$target_group_arn \
            --set albSecurityGroupId="sg-0823491d25edecd1d" \
            --timeout 10m \
            --wait \
            --debug || {
              echo "=== Helm deployment failed — dumping pod logs ==="
              kubectl describe pods -n $helm_namespace -l app=$helm_release_name
              kubectl logs -n $helm_namespace -l app=$helm_release_name --previous 2>/dev/null || true
              exit 1
            }
