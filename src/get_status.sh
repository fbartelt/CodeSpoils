#!/bin/bash
source ./config.sh

rank_overall=$(source src/rank_overall.sh $1 | \
  sed -E 's/.*name=([1-8])\s+(kyu|dan),\s+score=([0-9]+)/\1\2 (\3)/g')
languages=$(source src/rank_language.sh $1 | jq -r | \
  sed -E 's/:.*?name=([1-8])\s+(kyu|dan),\s+score=([0-9]+)/: \1\2 (\3);/')

ndash=$(echo -e ${languages} | tr ';' '\n' | column -t | \
  awk '/.*/ {print length}' | sort -n | tail -1)
dashes=$(printf "%${ndash}s")

echo -e "\e[1;${winner_color}m$1 ${rank_overall}\n${dashes// /-}\e[0m"
echo -e ${languages} | tr ';' '\n' | column -t