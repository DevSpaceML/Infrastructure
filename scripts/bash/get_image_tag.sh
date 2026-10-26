#!/bin/bash

get_img_tag()(
    local env=${1:?usage: get_img_tag <env> <app> <region>}
    local app=${2:?usage: get_img_tag <env> <app> <region>}
    local region=${3:?usage: get_img_tag <env> <app> <region>}
    local imgtag

    imgtag=$(aws ecr describe-images --repository-name "${env}/${app}" --region $region\
       --filter tagStatus=TAGGED \
       --query 'sort_by(imageDetails,&imagePushedAt)[-1].imageTags[0]' \
       --output text
    ) || return 1

    if [[ -z $imgtag || $imgtag == "None" ]]; then
       echo "No tagged images found in ${env}/{$app}" >&2
       return 1
    fi

    printf '%s\n' "$imgtag"
)

get_img_tag $1 $2 $3



