#!/bin/bash
source ./config.sh
################################################################################
# Help
################################################################################
help () {
  echo "Usage: codespoils [OPERATION] USER [USER2|PATH] [OPTIONS]"
  echo 
  echo "OPERATIONS:"
  echo "  -h, -?, --help             Display this help and exit"
  echo "  -p, --profile              Show USER profile: overall rank and"
  echo "                               languages rank"
  echo "  -r, --rank-up              Show minimum amount of kata in order to"
  echo "                               rank-up (overall or LANGUAGE)"
  echo "  -c, --compare              Head-to-head comparison with USER2"
  echo "  -t, --table-lang           Create table of completed kata per"
  echo "                               language"
  echo "  -k, --table-kyu            Create table of completed kata per"
  echo "                               kyu per language"
  echo "  -f, --file-names           Create filenames for the last N"
  echo "                               completed katas"
  echo "  -s, --search-missing       Search for missing files for completed"
  echo "                               katas in PATH"
  echo
  echo "OPTIONS:"
  echo "  -l, --language LANGUAGE    Specify programming language"
  echo "  -n, --N NUM                N parameter (kyu ceiling for rank-up and"
  echo "                               number of file names to generate)"
}
################################################################################
### Main Program
################################################################################4
warrior=""
second_arg="ignore"
option=0
option_n=1

while :; do
  case $1 in
    -h|-\?|--help)
      help; exit
      ;;
    -p|--profile)
      option=0
      if [ "$2" ]; then
        warrior=$2
        shift
      else
        echo "argument USER required"; exit
      fi
      ;;
    -r|--rank-up)
      option=1
      if [ "$2" ]; then
        warrior=$2
        shift
      else
        echo "argument USER required"; exit
      fi
      ;;
    -c|--compare)
      option=2
      if [ "$2" ]; then
        warrior=$2
        if [ "$3" ]; then
          second_arg=$3
          shift
        else
          echo "option requires an argument USER2 -- '$1'"; exit
        fi
        shift
      else
        echo "argument USER required"; exit
      fi
      ;;
    -t|--table-lang)
      option=3
      if [ "$2" ]; then
        warrior=$2
        shift
      else
        echo "argument USER required"; exit
      fi
      ;;
    -k|--table-kyu)
      option=4
      if [ "$2" ]; then
        warrior=$2
        shift
      else
        echo "argument USER required"; exit
      fi
      ;;
    -f|--file-names)
      option=5
      if [ "$2" ]; then
        warrior=$2
        shift
      else
        echo "argument USER required"; exit
      fi
      ;;
    -s|--search-missing)
      option=6
      if [ "$2" ]; then
        warrior=$2
        if [ "$3" ]; then
          second_arg=$3
          shift
        else
          second_arg="."
          echo "WARN: No PATH provided for $1. Using '.'."
        fi
        shift
      else
        echo "argument USER required"; exit
      fi
      ;;
    -l|--language)
      if [ "$2" ]; then
        second_arg=$2
        shift
      else
        echo "WARN: Must specify a language for $1. Ignoring option."
      fi
      ;;
    -n|--N)
      if [ "$2" ]; then
        option_n=$2
        shift
      else
        echo "WARN: Must specify a number for $1. Ignoring option."
      fi
      ;;
    --)
      shift
      break
      ;;
    -?*)
      printf 'WARN: Unknown option (ignored): %s\n' "$1" >&2
      ;;
    *)
      if [[ -z "${warrior}" ]]; then
        warrior=$1
      fi
      break
  esac
  shift
done

################################## VARIABLES ##################################

declare -A subscript_array=(
  [0]="get_profile"
  [1]="get_lvlup"
  [2]="compare_h2h"
  [3]="kata_per_lang"
  [4]="kata_per_kyu"
  [5]="get_file_names"
  [6]="search_missing"
)

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

################################## FUNCTIONS ##################################
rank_overall () {
  curl -s "https://www.codewars.com/api/v1/users/$1" | jq '.ranks.overall' | \
    jq '. | del(.color) | to_entries | map("\(.key)=\(.value|tostring)")' | \
    jq -r '. | join(",  ")'
}

rank_language () {
  curl -s "https://www.codewars.com/api/v1/users/$1" | jq '.ranks.languages' | \
    jq 'del(.[].color?)| to_entries | sort_by(.value.score) | reverse' | \
    jq 'map("\(.key):  \(.value | to_entries | map("\(.key)=\(.value)") | join(", "))")' | \
    jq -r '.[]'
}

# -p|--profile operation args:[USER]
get_profile () {
  rank_overall=$(rank_overall "$1" | \
    sed -E 's/.*name=([1-8])\s+(kyu|dan),\s+score=([0-9]+)/\1\2 (\3)/g')
  languages=$(rank_language "$1" | \
    sed -E 's/:.*?name=([1-8])\s+(kyu|dan),\s+score=([0-9]+)/: \1\2 (\3);/')
  ndash=$(echo -e ${languages} | tr ';' '\n' | column -t | \
    awk '/.*/ {print length}' | sort -n | tail -1)
  dashes=$(printf "%${ndash}s")
  echo -e "\e[1;${winner_color}m$1 ${rank_overall}\n${dashes// /-}\e[0m"
  echo -e ${languages} | tr ';' '\n' | column -t
}

# -r|--rank-up operation args:[USER LANGUAGE N]
get_lvlup () {
  kata_score=(1097 404 149 55 21 8 3 2)
  kyu_ceiling=1
  warrior_data=$(rank_overall "$1")
  warrior_score=$(echo ${warrior_data} | sed -E 's/.*score=([0-9]+).*/\1/')
  warrior_rank=$(echo ${warrior_data} | sed -E 's/.*rank=(-?[0-9]+).*/\1/')
  warrior_rank_name=$(echo ${warrior_data} | \
    sed -E 's/.*name=([1-8] )(kyu|dan).*/\1\2/')
  if [[ $# -gt 1 ]]; then
    if [[ "$2" != "ignore" ]]; then
      warrior_data=$(rank_language "$1" | tr '\n' ';')
      warrior_score=$(echo ${warrior_data} | \
        sed -E 's/.*?'$2'[^;]*?score=([0-9]+);.*?/\1/')
      warrior_rank=$(echo ${warrior_data} | \
        sed -E 's/.*?'$2'[^;]*?rank=(-?[1-8]+).*;.*?/\1/')
      warrior_rank_name=$(echo ${warrior_data} | \
        sed -E 's/.*?('$2': )[^;]*?name=([1-8] )(kyu|dan).*;.*?/\1\2\3/')
    fi
    if [ "$3" ]; then
      if [[ $3 -lt 1 || $3 -gt 8 ]]; then
        echo "ERR: -n (kyu ceiling) must be in [1,8]. Got $3"; exit
      fi
      kyu_ceiling="$3"
    fi
  fi
  next_rank=$((${warrior_rank} + 1))
  next_lvl=$((${rank_map[${next_rank}]}))
  curr_score=$((${next_lvl} - ${warrior_score}))
  echo -e "\e[1;${winner_color}m$1(${warrior_rank_name})\e[0m needs " \
    "${curr_score} score in order to Rank Up to \e[1;${winner_color}m" \
    "${rank_names[${next_rank}]}\e[0m.\nMinimum kata needed:"
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
}

color_score () {
  # color string as LOSER WINNER if 0, else WINNER LOSER.
  # args: [USER_SCORE USER2_SCORE USER_WINNER?]
  if [[ $3 -eq 0 ]]; then
    echo "\e[1;${loser_color}m$1 \e[1;${winner_color}m| $2\e[0m"
  else
    echo "\e[1;${winner_color}m$1 \e[1;${loser_color}m| $2\e[0m"
  fi
} 

# -c|--compare operation. args:[USER USER2]
compare_h2h () {
  str1=$(get_profile "$1")
  str2=$(get_profile "$2")
  w1_score=$(echo ${str1} | sed -E 's/^[^:]*\(([0-9]+)\).*/\1/') 
  w2_score=$(echo ${str2} | sed -E 's/^[^:]*\(([0-9]+)\).*/\1/') 
  final_str=""

  if [[ ${w1_score} -ge ${w2_score} ]]; then
    final_str="$(echo "${str1}" | head -1) $(echo "${str2}" | head -1 | \
      sed 's/\x1B\[1;'${winner_color}'m/\x1B\[1;'${loser_color}'m/')"
  else 
    final_str="$(echo "${str1}" | head -1 | \
      sed 's/\x1B\[1;'${winner_color}'m/\x1B\[1;'${loser_color}'m/') $(echo "${str2}" | head -1)"
  fi

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
}

show_progress () {
  # Progress bar. args [CURRENT TOTAL TEXT]
  percent=$(bc <<< "scale=${bar_resolution}; 100 * $1 / $2" )
  completed=$(bc <<< "scale=0; ${bar_size} * ${percent} / 100" )
  todo=$(bc <<< "scale=0; ${bar_size} - ${completed}" )
  done_sub_bar=$(printf "%${completed}s" | tr " " "${bar_char_done}")
  todo_sub_bar=$(printf "%${todo}s")

  printf "\r${3:-Progress} : [${done_sub_bar}${todo_sub_bar}] ${percent}%%"
  [[ $2 -eq $1 ]] && printf "\n"
}

iterate_katas_l () {
  # kata_per_lang version
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

iterate_pages_l () {
  # kata_per_lang version
  for page_num in $(seq 1 ${total_pages}); do
    page="$(curl -s "${base_url}page=${page_num}")"
    iterate_katas_l "${page}"
  done
}

# -t|--table-lang operation. args:[USER]
kata_per_lang () {
  base_url="https://www.codewars.com/api/v1/users/$1/code-challenges/completed?"
  page0="$(curl -s "${base_url}page=0")"
  total_pages=$(($(echo "${page0}" | jq -r '.totalPages') - 1))
  total_items=$(($(echo "${page0}" | jq -r '.totalItems') - 1))
  acc_items=0
  lang_json=$(rank_language $1 | sed -E 's/^(\w+):.*/"\1":0,/g' | sed '1i {' | \
    sed '$s/,$//g'  | sed '$a }' | jq -r)
  iterate_katas_l "${page0}"
  iterate_pages_l
  table="| Language | Total |\n| :--: | :---: |\n"
  table="${table}$(echo ${lang_json} | \
    jq 'to_entries | .[]' | \
    jq -r '. | "| \(.key | (.[:1]|ascii_upcase) + .[1:]) | \(.value) |"')"
  echo -e "${table}"
}

kata_info () {
  curl -s "https://www.codewars.com/api/v1/code-challenges/$1" | \
    jq -r '{rank_id:.rank.id, rank:.rank.name, url:.url}'
}

iterate_katas_k () {
  # kata_per_kyu version
  page_items=$(($(echo $1 | jq -r '.totalItems') - 1))
  for i in $(seq 0 ${page_items}); do
    show_progress "${acc_items}" "${total_items}" "Kata per kyu per Language"
    kata=$(echo $1 | jq -r '.data['${i}']')
    kata_id=$(echo "${kata}" | jq -r '.id')
    kata_langs=$(echo "${kata}" | jq -r '.completedLanguages[]?' | \
      tr '\n' ';' | sed 's/;$//g')
    kata_stats=$(echo $(kata_info "${kata_id}" | \
      jq -r '{rank_id:.rank_id, rank:.rank, lang:"'${kata_langs}'", url:.url}'| \
      sed 's/null/"beta"/'))
    kata_rank=$(echo ${kata_stats} | jq -r '.rank' | sed -E 's/\s+//g')
    kata_langs=$(echo ${kata_langs} | tr ';' ' ')
    # echo "${acc_items}  $(echo ${kata_stats} | jq -r '.url')"
    let "acc_items=${acc_items} + 1"
    for lang in ${kata_langs}; do
      lang_json=$(echo "${lang_json}" | jq '.'${lang}'."'${kata_rank}'"|=.+1')
    done
  done
}

iterate_pages_k () {
  # kata_per_kyu version
  for page_num in $(seq 1 ${total_pages}); do
    page="$(curl -s "${base_url}page=${page_num}")"
    iterate_katas_k "${page}"
  done
}

# -k|--table-kyu operation. args:[USER]
kata_per_kyu () {
  base_url="https://www.codewars.com/api/v1/users/$1/code-challenges/completed?"
  page0="$(curl -s "${base_url}page=0")"
  total_pages=$(echo "${page0}" | jq -r '.totalPages')
  total_items=$(($(echo "${page0}" | jq -r '.totalItems') - 1))
  acc_items=0
  kyus="\"1kyu\":0,\"2kyu\":0,\"3kyu\"\:0,\"4kyu\":0,\"5kyu\":0,\"6kyu\":0,\"7kyu\":0,\"8kyu\":0,\"beta\":0"
  lang_json=$(rank_language $1 | sed -E 's/^(\w+):.*/"\1":{'${kyus}'},/g' | \
    sed '1i {' | sed '$s/,$//g'  | sed '$a }' | jq -r)
  iterate_katas_k "${page0}"
  iterate_pages_k
  table=""
  for key in $(echo "${lang_json}" | jq -r 'keys_unsorted[]'); do
    table="${table}\n### ${key^}\n\n| Kyu  | Total |\n| :--: | :---: |\n"
    table="${table}$(echo -e "${lang_json}" | \
      jq -r '.'${key}' | to_entries | .[] | "| \(.key) | \(.value) |"' | \
      sed -E 's/kyu|dan//g' | sed -E 's/beta/\$\\\\beta\$/g')\n"
  done

  echo -e "${table}"
}

iterate_katas_f () {
  # get_file_name version
  page_items=$(($(echo $1 | jq -r '.data | length') - 1))
  rem=$((${total_items} - ${acc_items}))
  if [[ ${page_items} -ge ${rem} ]]; then
    page_items=${rem}
  fi
  
  for i in $(seq 0 ${page_items}); do
    kata=$(echo $1 | jq -r '.data['${i}']')
    kata_id=$(echo "${kata}" | jq -r '.id')
    kata_slug=$(echo "${kata}" | jq -r '.slug')
    kata_langs=$(echo "${kata}" | jq -r '.completedLanguages[]?' | tr '\n' ' ')
    kata_rank=$(echo $(kata_info "${kata_id}" | jq -r '.rank'| \
      sed 's/null/"beta"/' | sed -E 's/\s+//g' | sed 's/"//g'))
    kata_name=$(echo ${kata_slug} | sed 's/-/'${word_separator}'/g')
    let "acc_items=${acc_items} + 1"
    for lang in ${kata_langs}; do
      echo "${kata_rank}${rank_separator}${kata_name}.${extension_map[${lang}]}      (https://www.codewars.com/kata/${kata_id})"
    done
  done
}

iterate_pages_f () {
  # get_file_name version
  for page_num in $(seq 1 ${total_pages}); do
    if [[ ${acc_items} -eq ${total_items} ]]; then
      break
    fi
    page="$(curl -s "${base_url}page=${page_num}")"
    iterate_katas_f "${page}"
  done
}

# -f|--file-names operation. args:[USER dummy N]
get_file_names () {
  base_url="https://www.codewars.com/api/v1/users/$1/code-challenges/completed?"
  page0="$(curl -s "${base_url}page=0")"
  total_pages=$(($(echo "${page0}" | jq -r '.totalPages') - 1))
  total_items=$(($3 - 1))
  acc_items=0
  lang_json=$(rank_language "$1" | sed -E 's/^(\w+):.*/"\1":0,/g' | \
    sed '1i {' | sed '$s/,$//g'  | sed '$a }' | jq -r)
  iterate_katas_f "${page0}"
  iterate_pages_f
}

iterate_katas_s () {
  # search_missing version
  page_items=$(($(echo $1 | jq -r '.data | length') - 1))
  
  for i in $(seq 0 ${page_items}); do
    kata=$(echo $1 | jq -r '.data['${i}']')
    kata_id=$(echo "${kata}" | jq -r '.id')
    kata_slug=$(echo "${kata}" | jq -r '.slug')
    kata_langs=$(echo "${kata}" | jq -r '.completedLanguages[]?' | tr '\n' ' ')
    kata_rank=$(echo $(kata_info "${kata_id}" | jq -r '.rank'| \
      sed 's/null/"beta"/' | sed -E 's/\s+//g' | sed 's/"//g'))
    kata_name=$(echo ${kata_slug} | sed 's/-/'${word_separator}'/g')
    let "acc_items=${acc_items} + 1"

    for lang in ${kata_langs}; do
      file_name="${kata_rank}${rank_separator}${kata_name}.${extension_map[${lang}]}"
      find_out=$(find "${path}" -regex ".*${file_name}.*")
    
      if [[ -z ${find_out} ]]; then
        echo "${file_name}      (https://www.codewars.com/kata/${kata_id})"
      fi

    done

  done
}

iterate_pages_s () {
  # search_missing version
  for page_num in $(seq 1 ${total_pages}); do
    page="$(curl -s "${base_url}page=${page_num}")"
    iterate_katas_s "${page}"
  done
}

# -s|--search-missing operation. args:[USER PATH]
search_missing () {
  base_url="https://www.codewars.com/api/v1/users/$1/code-challenges/completed?"
  page0="$(curl -s "${base_url}page=0")"
  total_pages=$(($(echo "${page0}" | jq -r '.totalPages') - 1))
  total_items=$(($(echo "${page0}" | jq -r '.totalItems') - 1))
  acc_items=0
  lang_json=$(rank_language $1 | sed -E 's/^(\w+):.*/"\1":0,/g' | \
    sed '1i {' | sed '$s/,$//g'  | sed '$a }' | jq -r)
  path="$2"
  echo -e "MISSING FILES:\n"
  iterate_katas_s "${page0}"
  iterate_pages_s
}

################################################################################
### EXECUTION
################################################################################

if [[ ${warrior} || $1 ]]; then
  ${subscript_array[${option}]} ${warrior} ${second_arg} ${option_n}
else
  echo "argument USER required"; exit
fi