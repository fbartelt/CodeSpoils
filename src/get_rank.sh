spacing="  "
# echo -e "\e[1;91m$1\e[0m"
# jq '. | del(.color, .rank) | . |= with_entries(.key |= sub("^name$"; "rank"))' | \
curl -s https://www.codewars.com/api/v1/users/$1 | jq '.ranks.overall' | \
  jq '. | del(.color)' | \
  jq '. | to_entries | map("\(.key)=\(.value|tostring)") | join(",'"$spacing"'")' | \
  jq -r '.'

# printf "%26s\n" ' ' | tr ' ' '_'

# source codewars_test.sh | jq -r '.'