#!/bin/bash
curl -s https://www.codewars.com/api/v1/users/$1 | jq '.ranks.languages' | \
  jq 'del(.[].color?)| to_entries | sort_by(.value.score) | reverse' | \
  jq 'map("\(.key):  \(.value | to_entries | map("\(.key)=\(.value)") | join(", "))")' | \
  jq -r '.[]'