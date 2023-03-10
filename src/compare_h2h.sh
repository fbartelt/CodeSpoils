#!/bin/bash

source ./config.sh

str1=$(source src/get_status.sh $1)
str2=$(source src/get_status.sh $2)
w1_score=$(echo ${str1} | sed -E 's/^[^:]*\(([0-9]+)\).*/\1/') 
w2_score=$(echo ${str2} | sed -E 's/^[^:]*\(([0-9]+)\).*/\1/') 
final_str=""

if [[ ${w1_score} -ge ${w2_score} ]]; then
  final_str="$(echo "${str1}" | head -1) $(echo "${str2}" | head -1 | sed 's/\x1B\[1;'${winner_color}'m/\x1B\[1;'${loser_color}'m/')"
else
  final_str="$(echo "${str1}" | head -1 | sed 's/\x1B\[1;'${winner_color}'m/\x1B\[1;'${loser_color}'m/') $(echo "${str2}" | head -1)"
fi

color_score () {
  if [[ $3 -eq 0 ]]; then
    echo "\e[1;${loser_color}m$1 \e[1;${winner_color}m| $2\e[0m"
  else
    echo "\e[1;${winner_color}m$1 \e[1;${loser_color}m| $2\e[0m"
  fi
} 

str2=$(echo "${str2}" | sed '1,2d')

while IFS= read -r line; do
  if [[ !(("${line}" == *"$1"*) || ("${line}" =~ "-"+)) ]]; then
    lang=$(echo ${line} | sed -E 's/(\w+):.*/\1/')
    score=$(echo ${line} | sed -E 's/'${lang}':.*\(([0-9]+)\)/\1/')
    other=$(echo "${str2}" | grep -e "^${lang}:" | sed -E 's/'${lang}':\s+//')
    other_score=$(echo ${other} | sed -E 's/.*\(([0-9]+)\)/\1/')
    other_rank=$(echo ${other} | sed -E 's/([1-8](kyu|dan)).*/\1/')
    str2=$(echo "${str2}" | \
      sed -E '/'${lang}':\s+'${other_rank}'\s+\('${other_score}'\)/d')
    
    if [[ ${score} -ge ${other_score} ]]; then
      final_str="${final_str}\n$(color_score "${line}" "${other}" "1")"
    else
      final_str="${final_str}\n$(color_score "${line}" "${other}" "0")"
    fi
  fi
done <<< "${str1}"

while IFS= read -r line; do
    lang=$(echo ${line} | sed -E 's/(\w+):.*/\1/')
    other="${lang}: - -"
    rank_score=$(echo ${line} | sed -E 's/'${lang}':(.*)/\1/')
    final_str="${final_str}\n$(color_score "${other}" "${rank_score}" "0")"
done <<< "${str2}"

final_str=$(echo -e "${final_str}" | column -t)
ndash=$(echo -e "${final_str}" | sed -e 's/\x1b\[[0-9;]*m//g' | \
  awk '/.*/ {print length}' | sort -n | tail -1)
dashes=$(printf "%${ndash}s")
echo "${final_str}" | sed '1a '${dashes// /-}'' | \
  sed -E 's/(--+)/\x1B\[0m\x1B\[1m\1/'
