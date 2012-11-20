#!/usr/bin/env bash

readonly MODULE_INSTALL_HOOK=module_install
readonly MODULE_POST_INSTALL_HOOK=module_post_install
readonly MODULE_PRE_INSTALL_HOOK=module_pre_install

readonly OK=0
readonly ERROR=1
readonly SKIP=255

defib() {
  defib_module "Shocking $1..." "$1"
  if [ "$?" -ne 0 -a "$?" -ne 255 ]; then
    outp "Failed to install '$package'"
    cat "$log_file"
    die
  fi
}

defib_module() {
  local banner=$1
  local package=$2

  start_progress "$banner" &
  local pid=$!

  (
  if has_fun "$package"; then
    debug "Running hook '$package'"
    outp
    if ! eval "$package"; then
      die
    fi
    outp
  else
    MODULE=$package
    connect_module_leads "$package"
  fi
  ) >>$AED_LOG 2>&1

  stop_progress $pid $?
}

connect_module_leads() {
  local module_name="$1"
  local root_sup="${module_name}.sh"
  local platform_sup="${module_name}/${PLATFORM}/${PKG_MGR}.sh"

  try_load_module "${AED_MODULES}/${root_sup}" ||
    try_load_module "${AED_MODULES}/${platform_sup}" ||
    try_load_module "${AED_LOCAL_MODULES}/${root_sup}" ||
    try_load_module "${AED_LOCAL_MODULES}/${platform_sup}" ||
    die "Module detail missing, no such module '${module_name}'."
}

try_load_module() {
  debug "Trying to load '$1'"
  if [ -e "$1" ]; then
    debug "Running script '$1'..."
    outp
    source "$1" || die "Corrupt package detail found in '$1'."
    outp
    return 0
  else
    return 1
  fi
}

run_hook() {
  local hook="$1"
  shift
  $hook $@
  local ret=$?
  debug "Hook exited with status: $ret"
  if [ "$ret" -eq 255 ]; then
    die "Module triggered abort"
  fi
  return $ret
}

pkg_mgr() {
  local command=$1
  shift
  case $command in
    'install')
      pkg_mgr_install "$@"
      ;;
    'exists')
      if pkg_mgr_check "$1"; then
        exit $SKIP
      fi
      ;;
    *)
      die 'Unknown command'
      ;;
  esac
}

user_pre_install_hook() {
  debug "user defined hook (not_implemented)"
  return 0;
}

pkg_pre_install_hook() {
  if [ -n "$PKG_EXEC" ]; then
    debug "Scanning for ${PKG_EXEC}"
    missing_cmd "$PKG_EXEC"
  elif has_fun "$MODULE_PRE_INSTALL_HOOK"; then
    debug "Calling $MODULE_PRE_INSTALL_HOOK"
    $MODULE_PRE_INSTALL_HOOK
  else
    debug "no pre-install hooks"
    return 0
  fi
}

pkg_install_hook() {
  if [ -n "$PKG_NAME" ]; then
    pkg_mgr_install "$PKG_NAME"
  elif has_fun "$MODULE_INSTALL_HOOK"; then
    $MODULE_INSTALL_HOOK
  else
    return 255
  fi
}

pkg_post_install_hook() {
  if has_fun $MODULE_POST_INSTALL_HOOK; then
    $MODULE_POST_INSTALL_HOOK
  else
    return 0
  fi
}

user_post_install_hook() {
  return 0
}
