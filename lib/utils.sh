outp() {
  echo

  if [ $# -gt 0 ]; then
    __puts '>>' "$@"
  fi
}

debug() {
  [ -n "$DEBUG" ] && __puts '>' "DBG: $@"
}

die() {
  echo
  if [ -e "$1" ]; then
    __puts '>' "Fatal: $1"
  fi

  if [ "$BASH_SUBSHELL" -eq 0 ]; then
    outp "Project has flatlined!"
  fi
  exit 1
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

