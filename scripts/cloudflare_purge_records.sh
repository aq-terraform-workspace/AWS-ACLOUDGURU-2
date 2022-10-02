#!/bin/bash

# Reference:
# https://gist.github.com/slayer/442fa2fffed57f8409e0b23bd0673a92

EMAIL="tuananh.qaa@gmail.com"
KEY="505c36986c487a6de66df0c5669214bd91dd4"
ZONE_ID="f4d5519cecb762015da2a220e67e8ad9"

curl -s -X GET https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/dns_records?per_page=500 \
    -H "X-Auth-Email: ${EMAIL}" \
    -H "X-Auth-Key: ${KEY}" | jq .result[].id |  tr -d '"' | (
  while read id; do
    curl -s -X DELETE https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/dns_records/${id} \
      -H "X-Auth-Email: ${EMAIL}" \
      -H "X-Auth-Key: ${KEY}"
  done
  )