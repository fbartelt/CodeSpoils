#!/bin/bash
declare -A subscript_array=(
  [0]="./src/get_status.sh"
  [1]="./src/get_lvlup.sh"
  [2]="./src/compare_h2h.sh"
  [3]="./src/kata_per_lang.sh"
  [4]="./src/kata_per_kyu.sh"
)

warrior=""
second_arg="ignore"
option=0
option_n=1

################################################################################
# Help
################################################################################
help () {
  echo "Usage: codespoils [OPERATION] USERNAME [USERNAME2] [OPTIONS]"
  echo 
  echo "OPERATIONS:"
  echo "  -h, -?, --help             display this help and exit"
  echo "  -p, --profile              show user profile: overall rank and"
  echo "                               languages rank"
  echo "  -r, --rank-up              show minimum amount of kata in order to"
  echo "                               rank-up (overall or LANGUAGE)"
  echo "  -c, --compare              head-to-head comparison with USERNAME2"
  echo "  -t, --table-lang           create table of completed kata per"
  echo "                               language"
  echo "  -k, --table-kyu            create table of completed kata per"
  echo "                               kyu per language"
  echo "  -f, --file-names           create filenames for the last N"
  echo "                               completed katas"
  echo "  -s, --search-missing       search for missing files for completed"
  echo "                               katas"
  echo
  echo "OPTIONS:"
  echo "  -l, --language LANGUAGE    Specify programming language"
  echo "  -n, --N NUM                N parameter (kyu ceiling for rank-up and"
  echo "                               number of file names to generate)"
}
################################################################################
### Main Program
################################################################################
while :; do
  case $1 in
    -h|-\?|--help)
      help
      exit
      ;;
    -p|--profile)
      option=0
      if [ "$2" ]; then
        warrior=$2
        shift
      else
        echo "argument USER required"
        exit
      fi
      ;;
    -r|--rank-up)
      option=1
      if [ "$2" ]; then
        warrior=$2
        shift
      else
        echo "argument USER required"
        exit
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
          echo "option requires an argument USER2 -- '$1'"
          exit
        fi
        shift
      else
        echo "argument USER required"
        exit
      fi
      ;;
    -t|--table-lang)
      option=3
      if [ "$2" ]; then
        warrior=$2
        shift
      else
        echo "argument USER required"
        exit
      fi
      ;;
    -k|--table-kyu)
      option=4
      if [ "$2" ]; then
        warrior=$2
        shift
      else
        echo "argument USER required"
        exit
      fi
      ;;
    -f|--file-names)
      echo "TODO: Create names for last N completed kata"
      ;;
    -s|--search-missing)
      echo "TODO: Search missing files"
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

if [[ ${warrior} || $1 ]]; then
  source ${subscript_array[${option}]} ${warrior} ${second_arg} ${option_n}
else
  echo "argument USER required"
fi