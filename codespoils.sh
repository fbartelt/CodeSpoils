#!/bin/bash
declare -A subscript_array=(
  [0]="./src/get_status.sh"
  [1]="./src/get_lvlup.sh"
  [2]="./src/compare_h2h.sh"
)

warrior=""
second_arg=""
option=0
option_n=1

while :; do
  case $1 in
    -h|-\?|--help)
      echo "TODO"
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
        if [ "$3" ]; then
          second_arg=$3
          shift
        fi
        shift
      else
        echo "No USER"
        exit
      fi
      ;;
    -n|--N)
      if [ "$2" ]; then
        option_n=$2
      else
        echo "WARN: Must specify a number for $1"
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
  source ${subscript_array[${option}]} ${warrior} ${second_arg}
else
  echo "No USER"
fi