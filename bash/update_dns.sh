#set -v

#DOMAIN="approute.me"
#API_KEY="h1yXJ8VnBLLQ_AHtNK42Th8vDGvrAyXejSX"
#API_SECRET="DXtHNS4BnEdF5bT4zHYnHh"
#auth="${API_KEY}:${API_SECRET}"
#api_url="https://api.godaddy.com/v1/domains/$DOMAIN/records/NS/@"

HOSTED_ZONE_ID=$(aws route53 list-hosted-zones-by-name \
    --dns-name "approute.me" \
    --query "HostedZones[0].Id" \
    --output text)

HOSTED_ZONE_ID=${HOSTED_ZONE_ID#/hostedzone/}    

NS_RECORDS=$(aws route53 list-resource-record-sets \
    --hosted-zone-id "$HOSTED_ZONE_ID" \
   --query "ResourceRecordSets[?Type == 'NS'] | [0].ResourceRecords[*].Value") 

echo $NS_RECORDS    

#i=1
#echo "Domain is: $DOMAIN"
#echo "API KEY is : $API_KEY"
#echo "API SECRET is : $API_SECRET"
#echo "API URL is: $api_url"
#echo "AUTH secret: $auth"

#NS_PAYLOAD=$(cat <<EOF
#  [
#    {
#       "data": "approutedns.net",
#       "name": "@",
#       "type": "NS",
#       "ttl": 3600        
#    } 
#  ]
#EOF
#)

#echo "Authorization: sso-key $auth"

#curl -X GET "https://api.godaddy.com/v1/domains" \
#  -H "Authorization: sso-key $auth"

#echo "\n------------------- "  
 
#curl -X PUT "$api_url" \
#    -H "Authorization: sso-key $auth" \
#    -H "Content-Type: application/json" \
#    -d "$NS_PAYLOAD"