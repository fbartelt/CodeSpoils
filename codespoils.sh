#!/bin/bash
declare -A subscript_array=(
  [0]="./src/get_status.sh"
  [1]="./src/get_lvlup.sh"
  [2]="./src/compare_h2h.sh"
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
  echo "  -r, --rank-up              show minimum amount of kata in order to"
  echo "                               rank-up (overall or LANGUAGE)"
  echo "  -c, --compare              head-to-head comparison with USERNAME2"
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
    -c|--compare)
      option=2
      if [ "$2" ]; then
        warrior=$2
        if [ "$3" ]; then
          second_arg=$3
          shift
        else
          echo "No USER to compare to"
          exit
        fi
        shift
      else
        echo "No USER"
        exit
      fi
      ;;
    -f)
      echo "TODO: Create names for last N completed kata"
      ;;
    -s|--search-missing)
      echo "TODO: Search missing files"
      ;;
    -r|--rank-up)
      option=1
      if [ "$2" ]; then
        warrior=$2
        shift
      else
        echo "No USER"
        exit
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
      break
  esac
  shift
done

if [[ ${warrior} || $1 ]]; then
  source ${subscript_array[${option}]} ${warrior} ${second_arg} ${option_n}
else
  echo "No USER"
fi