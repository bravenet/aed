#!/usr/bin/env bash

readonly MODULE_INSTALL_HOOK=module_install
readonly MODULE_POST_INSTALL_HOOK=module_post_install
readonly MODULE_PRE_INSTALL_HOOK=module_pre_install

defib() {
  clear_env

  if has_fun "$1"; then
    if ! eval "$1"; then
      die "Custom hook returned non-zero status"
    fi
  else
    if ! connect_module_leads "$1"; then
      return $?
    else
      shock_package "$1"
    fi
  fi
}

clear_env() {
  unset PKG_NAME
  unset PKG_EXEC
  unset "$MODULE_PRE_INSTALL_HOOK"
  unset "$MODULE_INSTALL_HOOK"
  unset "$MODULE_POST_INSTALL_HOOK"
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
    source "$1" || die "Corrupt package detail found in '$1'."
  else
    return 1
  fi
}

shock_package() {
  outp "Installing $1..."

  if run_hook user_pre_install_hook "$1"; then

    if run_hook pkg_pre_install_hook "$1"; then
      if run_hook pkg_install_hook "$1"; then
        run_hook pkg_post_install_hook "$1"
      else
        die "Failed to install $1."
      fi
    else
      outp "already installed, skipping."
    fi

    run_hook user_post_install_hook "$1"
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
