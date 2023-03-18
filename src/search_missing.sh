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
word_separator="_"
rank_separator="-"
path="$2"


declare -A extension_map=(
  ["agda"]="agda"
  ["bf"]="b"
  ["c"]="c"
  ["cfml"]="cfml"
  ["clojure"]="clj"
  ["cobol"]="cbl"
  ["coffeescript"]="coffee"
  ["commonlisp"]="lisp"
  ["coq"]="v"
  ["cpp"]="cpp"
  ["crystal"]="cr"
  ["csharp"]="cs"
  ["d"]="d"
  ["dart"]="dart"
  ["elixir"]="ex"
  ["elm"]="elm"
  ["erlang"]="erl"
  ["factor"]="factor"
  ["forth"]="4th"
  ["fortran"]="f95"
  ["fsharp"]="fs"
  ["go"]="go"
  ["groovy"]="groovy"
  ["haskell"]="hs"
  ["haxe"]="hx"
  ["idris"]="idr"
  ["java"]="java"
  ["javascript"]="js"
  ["julia"]="jl"
  ["kotlin"]="kt"
  ["lambdacalc"]="lambdacalc"
  ["lean"]="lean"
  ["lua"]="lua"
  ["nasm"]="asm"
  ["nim"]="nim"
  ["objc"]="m"
  ["ocaml"]="ml"
  ["pascal"]="pas"
  ["perl"]="pl"
  ["php"]="php"
  ["powershell"]="ps1"
  ["prolog"]="pl"
  ["purescript"]="purs"
  ["python"]="py"
  ["r"]="r"
  ["racket"]="rkt"
  ["raku"]="raku"
  ["reason"]="re"
  ["riscv"]="riscv"
  ["ruby"]="rb"
  ["rust"]="rs"
  ["scala"]="scala"
  ["shell"]="sh"
  ["solidity"]="sol"
  ["sql"]="sql"
  ["swift"]="swift"
  ["typescript"]="ts"
  ["vb"]="vb"
)

kata_info () {
  curl -s "https://www.codewars.com/api/v1/code-challenges/$1" | \
    jq -r '{rank_id:.rank.id, rank:.rank.name, url:.url}'
}

iterate_katas_s () {
  page_items=$(($(echo $1 | jq -r '.data | length') - 1))
  
  for i in $(seq 0 ${page_items}); do
    # show_progress "${acc_items}" "${total_items}" "Kata per Language"
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
      # echo "${find_out}"
      if [[ -z ${find_out} ]]; then
        echo "${file_name}      (https://www.codewars.com/kata/${kata_id})"
      fi
      # lang_json=$(echo "${lang_json}" | jq '.'${lang}'|=.+1')
    done
  done
}

iterate_pages_s () {
  for page_num in $(seq 1 ${total_pages}); do
    page="$(curl -s "${base_url}page=${page_num}")"
    iterate_katas_s "${page}"
  done
}

echo -e "MISSING FILES:\n"
iterate_katas_s "${page0}"
iterate_pages_s