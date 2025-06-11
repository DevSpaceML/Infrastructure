
update_vars() {
    
    #CLUSTER_NAME="$1"

    yaml_file='/opt/homebrew/var/infrastructure/eks/yaml/deploy_eksapp.yaml'

   cert_arn=$(aws acm list-certificates --query "CertificateSummaryList[].CertificateArn" --output text)

    echo "retrieved cert arn : $cert_arn"

    # use yq to write cert arn to yaml file.
    echo "writing variables to yaml file"
    
    yq eval ".metadata.annotations.\"alb.ingress.kubernetes.io/certificate-arn\" = \"${cert_arn}\" " -i "${yaml_file}"

}

update_vars
