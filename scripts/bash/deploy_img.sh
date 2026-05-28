# Create Docker Image
#RepoName=$1, ImgName=$2

set -v
echo "checking for existing repo..."
r=$(aws ecr describe-repositories)
count=$(echo "$r" | jq '.repositories | length')
tag=$(date +%Y%m%d-%H%M%S)
platform="linux/arm64"
appname="gemapp"

echo $count
echo "------------------"

for ((i=0; i<$count;i++))
do      
    repo_name=$(echo "$r" | jq -r ".repositories[$i].repositoryName")
    repo_uri=$(echo "$r" | jq -r ".repositories[$i].repositoryUri")
    img_tag=$(echo "$repo_uri/${repo_name}:$tag")
    echo $repo_name
    echo $repo_uri
    echo $img_tag
    echo "********"

    #Build docker image and push to repo
done

createdockerimg (){
    app_location='/Library/WebServer/Documents/LindoTofo'
    repouri="586098609239.dkr.ecr.us-east-1.amazonaws.com/gem/gemapp"
    ImgTag="$repouri:$tag"
    cd $app_location

    docker buildx build  --platform $platform -t $appname . 
    docker tag "$appname:$img_tag" $ImgTag
   # docker push $ImgTag    
}

createdockerimg



