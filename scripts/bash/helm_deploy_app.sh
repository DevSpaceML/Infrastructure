#!/bin/bash

# Gather output values
rootdir="/opt/homebrew/var/deploy/infrastructure"
cluster_dir="$rootdir/environments/dev/compute/eks_cluster"
eks_rtng_dir="$rootdir/environments/dev/alb/eks-routing"

echo "gathering outputs for variables >>>"

get_img_tag()(
    local env=${1:?usage: get_img_tag <env> <app>}
    local app=${2:?usage: get_img_tag <env> <app>}

    imgtag=$(aws ecr describe-images --repository-name "${env}/${app}" \
       --filter tagStatus=TAGGED \
       --query 'sort_by(imageDetails,&imagePushedAt)[-1].imageTags[0]' \
       --output text
    ) || return 1

    if [[ -z $imgtag || $imgtag == "None" ]]; then
       echo "No tagged images found in ${env}/{$app}" > 2
       return 1
    fi

    printf "$imgtag"
)

clustername=$(terraform -chdir=$cluster_dir output -raw cluster_name | cut -d'=' -f2-)
alb_sec_group_id=$(terraform -chdir=$cluster_dir output -raw alb_sec_group_id | cut -d'=' -f2-)
target_group_arn=$(terraform -chdir=$eks_rtng_dir output -raw tgtgrp_arn | cut -d'=' -f2-)

echo "cluster name: $clustername"
echo "security group Id: $alb_sec_group_id"
echo "target group arn: $target_group_arn"

# set variables

env=$1
app=$2
region="us-east-1"
image_repository="488347380548.dkr.ecr.us-east-1.amazonaws.com/$env/$app"
helm_release_name="$app"
projectname="$app"
helm_chart_path="$rootdir/helm-charts/gem-app/dev/ephmrl"
helm_namespace="ns-$app"
aws_default_region="us-east-1"
aws_region="us-east-1"
appversion=$(get_img_tag $env $projectname)

echo "app version: $appversion"

# Update kube config and run preflight check
 aws eks update-kubeconfig --name $clustername --region $region

      - name: Helm-Pre-flight-Check
        run: |
          echo "=== Helm template dry-run — checking for manifest errors ==="
          helm template $helm_release_name $helm_chart_path \
            --namespace $helm_namespace \
            --values $helm_chart_path/values.yaml \
            --set image.repository=$image_repository \
            --set image.tag=$appversion \
            --set targetGroupBinding.targetGroupArn="$target_group_arn" \
            --set targetGroupBinding.securityGroupId="$alb_sec_group_id" \
            --set environment=$env \
            --debug 2>&1 | tee /tmp/helm-template-output.txt

# deploy app
 helm upgrade --install $helm_release_name $helm_chart_path \
            --namespace $helm_namespace --create-namespace \
            --values $helm_chart_path/values.yaml \
            --set image.repository="$image_repository" \
            --set app.name="$helm_release_name" \
            --set image.tag="$appversion" \
            --set environment="$env" \
            --set targetGroupBinding.targetGroupArn="$target_group_arn" \
            --set targetGroupBinding.securityGroupId="$alb_sec_group_id" \
            --timeout 10m \
            --wait \
            --debug || {
              echo "=== Helm deployment failed — dumping pod logs ==="
              kubectl describe pods -n $helm_namespace -l app=$helm_release_name
              kubectl logs -n $helm_namespace -l app=$helm_release_name --previous 2>/dev/null || true
              exit 1
            }


