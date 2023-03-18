#!/bin/bash
base_url="https://www.codewars.com/api/v1/users/$1/code-challenges/completed?"
page0="$(curl -s "${base_url}page=0")"
total_pages=$(($(echo "${page0}" | jq -r '.totalPages') - 1))
total_items=$(($(echo "${page0}" | jq -r '.totalItems') - 1))
acc_items=0
lang_json=$(source src/rank_language.sh $1 | sed -E 's/^(\w+):.*/"\1":0,/g' | \
  sed '1i {' | sed '$s/,$//g'  | sed '$a }' | jq -r)
bar_size=40
bar_char_done="#"
bar_resolution=1

show_progress () {
  # show_progress CURRENT TOTAL TEXT
  percent=$(bc <<< "scale=${bar_resolution}; 100 * $1 / $2" )
  done=$(bc <<< "scale=0; ${bar_size} * ${percent} / 100" )
  todo=$(bc <<< "scale=0; ${bar_size} - ${done}" )

  done_sub_bar=$(printf "%${done}s" | tr " " "${bar_char_done}")
  todo_sub_bar=$(printf "%${todo}s")

  printf "\r${3:-Progress} : [${done_sub_bar}${todo_sub_bar}] ${percent}%%"
  [[ $2 -eq $1 ]] && printf "\n"
}

iterate_katas () {
  page_items=$(($(echo $1 | jq -r '.data | length') - 1))
  
  for i in $(seq 0 ${page_items}); do
    show_progress "${acc_items}" "${total_items}" "Kata per Language"
    kata=$(echo $1 | jq -r '.data['${i}']')
    kata_id=$(echo "${kata}" | jq -r '.id')
    kata_langs=$(echo "${kata}" | jq -r '.completedLanguages[]?' | tr '\n' ' ')
    let "acc_items=${acc_items} + 1"
    for lang in ${kata_langs}; do
      lang_json=$(echo "${lang_json}" | jq '.'${lang}'|=.+1')
    done
  done
}

iterate_pages () {
  for page_num in $(seq 1 ${total_pages}); do
    page="$(curl -s "${base_url}page=${page_num}")"
    iterate_katas "${page}"
  done
}

iterate_katas "${page0}"
iterate_pages
table="| Language | Total |\n| :--: | :---: |\n"
table="${table}$(echo ${lang_json} | \
  jq -r 'to_entries | .[] | "| \(.key | (.[:1]|ascii_upcase) + .[1:]) | \(.value) |"')"

echo -e "${table}"