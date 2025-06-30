# Create Docker Image
#RepoName=$1, ImgName=$2

set -v
echo "checking for existing repo..."
r=$(aws ecr describe-repositories)
count=$(echo "$r" | jq '.repositories | length')
platform="linux/arm64"
appname="tiyeni"


echo $count
echo "------------------"

for ((i=0; i<$count;i++))
do      
    repo_name=$(echo "$r" | jq -r ".repositories[$i].repositoryName")
    repo_uri=$(echo "$r" | jq -r ".repositories[$i].repositoryUri")
    img_tag=$(echo "$repo_uri/${repo_name}:latest")
    echo $repo_name
    echo $repo_uri
    echo $img_tag
    echo "********"

    #Build docker image and push to repo
done

#312907937200.dkr.ecr.us-east-1.amazonaws.com/tiyeni-app
createdockerimg (){
    app_location='/Library/WebServer/Documents/LindoTofo'
    repouri="312907937200.dkr.ecr.us-east-1.amazonaws.com/tiyeni-app"
    ImgTag="$repouri:latest"
    cd $app_location

    docker buildx build  --platform $platform -t $appname . 
    docker tag "$appname:latest" $ImgTag
    docker push $ImgTag    
}

createdockerimg



