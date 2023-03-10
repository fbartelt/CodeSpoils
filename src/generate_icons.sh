#!/bin/bash

source ./config.sh

rep_icon=$(echo ${!iconMap[*]} | sed 's/ /|/g')
html_icon=$(source ./codewars_test.sh $1 | jq -r '.' | \
  sed -E 's/(\w+).*([0-9])\s(kyu|dan).*$/<img src=\"https:\/\/img.shields.io\/badge\/\2\3-'${bgcolor}'.svg?\&style=for-the-badge\&logo=\1\&logoColor='${logocolor}'\&logoWidth='${logoWidth}'\" height=\"'${height}'\"\/>/g')
final=""

for html_part in ${html_icon}; do
  if [[ ${html_part} =~ (.*logo=)(${rep_icon})(.*$) ]]; then
    mapped_icon="${iconMap[${BASH_REMATCH[2]}]}"
    final=${final}" "${BASH_REMATCH[1]}${mapped_icon}${BASH_REMATCH[3]}
  else
    final=${final}" "${html_part}
  fi
done

echo ${final} | sed 's/> />\n/g'

