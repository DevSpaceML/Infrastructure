#!/bin/bash

set -euo pipefail
set -v

# Update kubeconfig with cluster admin role
aws eks update-kubeconfig \
  --region us-east-1 \
  --name taurus \
  --profile ClusterAdmin

echo "Current kubeconfig context:"
kubectl config current-context

echo "Verifying IAM identity:"
aws sts get-caller-identity

echo "Applying aws-auth ConfigMap update:"
kubectl apply -f /opt/homebrew/var/infrastructure/eks/yaml/k8s_auth.yaml --validate=false
