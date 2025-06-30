#!/bin/bash


CertInfo=$(aws acm list-certificates)

echo $CertInfo
echo "------------"

CertArn=$(aws acm list-certificates --query "CertificateSummaryList[].CertificateArn" --output text)

echo $CertArn

tags=$(aws acm list-tags-for-certificate --certificate-arn $CertArn)

echo $tags

#for cert_arn in $(aws acm list-certificates --query "CertificateSummaryList[].CertificateArn" --output text); do
#  tags=$(aws acm list-tags-for-certificate --certificate-arn "$cert_arn")
#  if echo "$tags" | jq -e --arg CLUSTER_NAME "$CLUSTER_NAME" '.Tags[] | select(.Key=="DeployedToCluster" and .Value==$CLUSTER_NAME)' > /dev/null; then
#    echo "Match found: $cert_arn"
#  fi
#done

