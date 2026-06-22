# Create and Push Image
set -x
set -e

ecr_login(){
    local ecr_root=$1
    aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $ecr_root
}

build_image (){
    local appname=$1
    local env=$2
    local platform="linux/arm64"
    local ecr_home="488347380548.dkr.ecr.us-east-1.amazonaws.com"
    local repo="$env/$appname"
    local app_root="/Library/WebServer/Documents/$appname" # store in guthub secrets or SSM parameter store
    local img_name="$appname"
    local tag="$appname-$(date +%Y%m%d-%H%M%S)"
    local destination="$ecr_home/$repo:$tag"

    cd $app_root

    docker buildx build  --platform $platform -t $img_name .
    docker tag $img_name $destination

    ecr_login $ecr_home
    docker push $destination
}

build_image $1 $2