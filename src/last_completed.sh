#!/bin/bash
base_url="https://www.codewars.com/api/v1/users/$1/code-challenges/completed?"
page0="$(curl -s "${base_url}page=0")"
total_pages=$(echo "${page0}" | jq -r '.totalPages')
kyus="\"1kyu\":0,\"2kyu\":0,\"3kyu\"\:0,\"4kyu\":0,\"5kyu\":0,\"6kyu\":0,\"7kyu\":0,\"8kyu\":0,\"beta\":0"
lang_json=$(source src/rank_language.sh $1 | sed -E 's/^(\w+):.*/"\1":{'${kyus}'},/g' | \
  sed '1i {' | sed '$s/,$//g'  | sed '$a }' | jq -r) 
declare -A rank_count=(
  ["8kyu"]=0
  ["7kyu"]=0
  ["6kyu"]=0
  ["5kyu"]=0
  ["4kyu"]=0
  ["3kyu"]=0
  ["2kyu"]=0
  ["1kyu"]=0
  ["beta"]=0
  )

kata_info () {
  curl -s "https://www.codewars.com/api/v1/code-challenges/$1" | \
    jq -r '{rank_id:.rank.id, rank:.rank.name, url:.url}'
}

iterate_kata () {
  total_items=$(($(echo $1 | jq -r '.totalItems') - 1))
  echo ${total_items}
  for i in $(seq 0 ${total_items}); do
    kata=$(echo $1 | jq -r '.data['${i}']')
    kata_id=$(echo "${kata}" | jq -r '.id')
    kata_langs=$(echo "${kata}" | jq -r '.completedLanguages[]?' | \
      tr '\n' ';' | sed 's/;$//g')
    kata_stats=$(echo $(kata_info "${kata_id}" | \
      jq -r '{rank_id:.rank_id, rank:.rank, lang:"'${kata_langs}'", url:.url}'| \
      sed 's/null/"beta"/'))
    kata_rank=$(echo ${kata_stats} | jq -r '.rank' | sed -E 's/\s+//g')
    kata_langs=$(echo ${kata_langs} | tr ';' ' ')
    # echo "${kata_stats}"
    for lang in ${kata_langs}; do
      lang_json=$(echo "${lang_json}" | jq '.'${lang}'."'${kata_rank}'"|=.+1')
    done
    # if [[ ${kata_langs} =~ .*${language}.* ]]; then
    #   # echo "AAA"
    #   echo "${kata_stats}" 
    #   kata_rank=$(echo "${kata_stats}" | jq -r '.rank' | sed -E 's/\s+//g')
    #   # echo "${kata_rank}"
    #   rank_count["${kata_rank}"]=$((rank_count["${kata_rank}"] + 1))
    # fi
  done
}


iterate_kata "${page0}"
table=""
echo "${lang_json}"
table=""
for key in $(echo "${lang_json}" | jq -r 'keys_unsorted[]'); do
  table="${table}\n### ${key^}\n\n| Kyu  | Total |\n| :--: | :---: |\n"
  table="${table}$(echo -e "${lang_json}" | \
    jq -r '.'${key}' | to_entries | .[] | "| \(.key) | \(.value) |"' | \
    sed -E 's/kyu|dan//g' | sed -E 's/beta/\$\\\\beta\$/g')\n"
  # "| \(.key) | \(.value) |"
  # table="${table}\n| ${kyu} | ${rank_count[$i]} |"
done

echo -e "${table}" > LANGTABLE.md

# for i in ${!rank_count[@]}; do
#   kyu=$(echo ${i} | sed -E 's/(kyu|dan)//g')
#   table="${table}\n| ${kyu} | ${rank_count[$i]} |"
# done

# table=$(echo -e "${table}" | sort | \
#   sed '1a ### '${language}'\n\n| Kyu  | Total |\n| :--: | :---: |')
# echo "${table}" > LANGTABLE.md
# for i in $(seq 1 ${total_pages}); do
#   page=$(curl -s "${base_url}page=${i}")
#   iterate_kata ${page}
# done
