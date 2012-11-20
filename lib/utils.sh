outp() {
  echo

  if [ $# -gt 0 ]; then
    __puts '>>' "$@"
  fi
}

debug() {
  __puts '>' "DBG: $@" >> $AED_LOG
}

die() {
  echo
  if [ -n "$1" ]; then
    __puts '>' "Fatal: $1"
  fi

  if [ "$BASH_SUBSHELL" -eq 0 ]; then
    outp "Project has flatlined!"
  fi
  exit 1
}

start_progress() {
  echo -n "> $1"
  while true; do
    echo -n "."
    sleep 1
  done
}

stop_progress() {
  kill $1
  wait $1 2> /dev/null

  case "$2" in
    0 )
      echo -n "done"
      ;;
    255 )
      echo -n "skipped"
      ;;
    * )
      echo -n "aborted"
      ;;
  esac
  echo
  return $2
}

missing_cmd() {
  if ! has_cmd $1; then
    return 0
  else
    return 1
  fi
}

has_cmd() {
  type "$1" &> /dev/null;
}

has_fun() {
  declare -F -f $1 &> /dev/null
}

__puts() {
  local prefix=$1; shift

  echo "$prefix $@"
}

