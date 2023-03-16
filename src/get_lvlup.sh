#!/bin/bash
source ./config.sh
# get_lvlup USER [LANGUAGE]
declare -A rank_names=(
  ["-7"]="7kyu"
  ["-6"]="6kyu"
  ["-5"]="5kyu"
  ["-4"]="4kyu"
  ["-3"]="3kyu"
  ["-2"]="2kyu"
  ["-1"]="1kyu"
  ["0"]="1dan"
  ["2"]="2dan"
  ["3"]="8kyu"
  )

# Score needed for Rank N (1 changed to 0 because of +1)
declare -A rank_map=(
  ["-7"]="20"
  ["-6"]="76"
  ["-5"]="229"
  ["-4"]="643"
  ["-3"]="1768"
  ["-2"]="4829"
  ["-1"]="13147"
  ["0"]="35759"
  ["2"]="97225"
  ["3"]="0"
  )
# Score per Kata kyu (1kyu 2kyu 3kyu ...)
kata_score=(1097 404 149 55 21 8 3 2)
kyu_ceiling=1

warrior_data=$(source src/rank_overall.sh $1)
warrior_score=$(echo ${warrior_data} | sed -E 's/.*score=([0-9]+).*/\1/')
warrior_rank=$(echo ${warrior_data} | sed -E 's/.*rank=(-?[0-9]+).*/\1/')
warrior_rank_name=$(echo ${warrior_data} | \
  sed -E 's/.*name=([1-8] )(kyu|dan).*/\1\2/')

if [[ $# -gt 1 ]]; then
  if [[ "$2" != "ignore" ]]; then
    warrior_data=$(source src/rank_language.sh $1 | jq -r '.' | tr '\n' ';')
    warrior_score=$(echo ${warrior_data} | sed -E 's/.*?'$2'[^;]*?score=([0-9]+);.*?/\1/')
    warrior_rank=$(echo ${warrior_data} | sed -E 's/.*?'$2'[^;]*?rank=(-?[1-8]+).*;.*?/\1/')
    warrior_rank_name=$(echo ${warrior_data} | \
      sed -E 's/.*?('$2': )[^;]*?name=([1-8] )(kyu|dan).*;.*?/\1\2\3/')
  fi
  if [ "$3" ]; then
    if [[ $3 -lt 1 || $3 -gt 8 ]]; then
      echo "Error: -n (kyu ceiling) must be in [1,8]. Got $3"
      exit
    fi
    kyu_ceiling="$3"
  fi
fi

next_rank=$((${warrior_rank} + 1))
next_lvl=$((${rank_map[${next_rank}]}))

curr_score=$((${next_lvl} - ${warrior_score}))
echo -e "\e[1;${winner_color}m$1(${warrior_rank_name})\e[0m needs ${curr_score} score" \
  "in order to Rank Up to \e[1;${winner_color}m${rank_names[${next_rank}]}\e[0m.\nMinimum kata needed:"
needed_kata=()

for i in ${!kata_score[@]}; do
  if [[ $((${i} + 1)) -ge ${kyu_ceiling} ]]; then
    needed_kata+=("$((${i} + 1))kyu: $((${curr_score} / ${kata_score[${i}]})),")
    curr_score=$((${curr_score} % ${kata_score[${i}]}))
  fi
done

# Remove 0s AND trailing commas and spaces AND add BOLD font 
echo -e $(echo -e ${needed_kata[@]} | sed -E 's/[1-8]+(kyu|dan):\s+0,//g' | \
  sed -E 's/\s+/ /g' | sed -E 's/,\s*$//g' | sed -E 's/^\s+//g' | \
  sed -E 's/([1-8])(kyu|dan)/\\e\[1m\1\2\\e\[0m/g')
