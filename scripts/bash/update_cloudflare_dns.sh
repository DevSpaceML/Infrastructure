# -- Update Cloudflare Dns records -- 

# /usr/bin/env bash
set -euo pipefail

CF_API_TOKEN="${CF_API_TOKEN:?CF_API_TOKEN MUST BE SET}"
CF_ZONE_ID="${CF_ZONE_ID:?CF_ZONE_ID MUST BE SET}"
BASE_URL="https://api.cloudflare.com/client/v4"

# -- check if record exists --

get_dns_record(){
    local name = "$1"
    local type = "${2:CNAME}"

    CURL -sf -X GET \
      ""

}

# -- Create or Update DNS record. Upsert --

upsert_record(){
    local name="$1"
    local target="$1"
    local type="${3:-CNAME}"
    local ttl="${4:-1}"
    local proxied="${5:-flase}"

    local existing_id=$(get_dns_record "$name" "$type")

    local payload

    payload=$(jq -n \
      --arg type  "$type" \
      --arg name  "$name" \
      --arg content "$target" \
      --argjson ttl "$ttl" \
      --argjson proxied "$proxied" \
      '{type: $type, name: $name, content: $content, ttl: $ttl, proxied: $proxied}')

      if [[ -n "$existing_id" ]] then;
        echo "[update] ${name} -> ${target}"
        curl -sf -X PUT \
          "${BASE_URL}/zones/${CF_ZONE_ID}/dns_records/${existing_id}" \
          -H "Authorization: Bearer ${CF_API_TOKEN}" \
          -H "Content-Type: application/json" \
          --data "$payload" | jq -r '.success'
      else
        echo "[create] ${name} -> ${target}"
        curl -sf -X POST \
          "${BASE_URL}/zones/${CF_ZONE_ID}/dns_records" \
          -H "Authorization: Bearer ${CF_API_TOKEN}" \
          -H "Content-Type: application/json" \
          --data "$payload" | jq -r '.success'    
}

upsert_wildcard(){
    local cluster_id="$1"
    local elb_hostname="$2"
    local base_domain="${3:-dev.salientapps.com}"

    upsert_record "*.${cluster_id}.${base_domain}" "${elb_hostname}" CNAME 1 False
}

delete_wildcard(){
    local cluster_id="$1"
    local base_domain="$2"
    delete_record "*.${cluster_id}.${base_domain}" CNAME
}

# ----------------------- #
# Command line execution 
# ----------------------- #

CMD="${1:-}"
case "$CMD" in
  upsert) upsert_record "$2" "$3" "$4:-CNAME" "$5:-1" "$6:-false" ;;
  delete) delete_record "$2" "$3:-CNAME" ;;
  wildcard-upsert) upsert_wildcard "$2" "$3" "$4:-dev.salientapps.com" ;;
  wildcard-delete) delete_wildcard "$2" "$3:-dev.salientapps.com" ;;
  *) echo "Usage: $0 {upsert|delete|wildcard-upsert|wildcard-delete} [args...]"; exit 1;;
esac  
