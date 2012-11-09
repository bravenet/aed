source_config_file() {
  if [[ -e "${AED_CONFIG}" ]]; then
    debug "sourcing local ${AED_CONFIG} file"
    source "${AED_CONFIG}" || die "Could not load ${AED_CONFIG}."
  fi

  detect_platform
  if ! detect_package_manager; then
    die "Cannot proceed without a package manager installed"
  fi
}

append_config() {
  if [ ! -e ${AED_CONFIG} ]; then
    debug "creating local ${AED_CONFIG} file"
    touch ${AED_CONFIG}
  fi

  local line="$1=\${$1:=$2}"
  echo "$line" >> "${AED_CONFIG}"
}

detect_platform() {
  if [ -n "$PLATFORM" ]; then
    return 0
  fi

  outp "Detecting platform..."
  if [[ "$OSTYPE" =~ ^darwin ]]; then
    PLATFORM="osx"
    outp "Detected '$PLATFORM'"
  fi

  if [ -z "$PLATFORM" ]; then
    die "Could not detect platform"
  else
    append_config "PLATFORM" "$PLATFORM"
  fi
}

detect_package_manager() {
  if [ -n "$PKG_MGR" ]; then
    local pkg_mgr_sup="${AED_LIB}/platform/${PLATFORM}/${PKG_MGR}.sh"
    debug "sourcing ${pkg_mgr_sup}"
    source "$pkg_mgr_sup" || die "Failed to load '$PKG_MGR', '$pkg_mgr_sup' may be corrupt"
    return 0
  fi

  outp "Looking for package manager..."
  local platform_managers="${AED_LIB}/platform/${PLATFORM}/*"

  local managers=()
  local descriptions=()

  for manager in ${platform_managers}; do
    source "$manager" || die "Cannot source '$manager'"

    local filename=$(basename $manager)
    local pkg_mgr=${filename%.*}

    managers+=("$pkg_mgr")
    descriptions+=("$PKG_MGR_DESC")

    if has_pkg_mgr; then
      PKG_MGR="$pkg_mgr"
      outp "Detected '$PKG_MGR'."
      break
    fi
  done

  if [ -n "$PKG_MGR" ]; then
    append_config "PKG_MGR" "$PKG_MGR"
    return 0
  fi

  outp "No package managers were detected for your platform."
  outp "Choose a supported package manager:"
  outp

  local options=()
  for index in $(seq 0 $((${#managers[@]} - 1))); do
    options+=("${managers[$index]} - ${descriptions[$index]}")
  done
  options+=('abort - Do not install any package manager')

  select chosen in "${options[@]}"; do
    case $REPLY in
      ${#options[@]})
        return 1
        ;;
      *)
        PKG_MGR="${managers[$(($REPLY - 1))]}"
        source "${AED_LIB}/platform/${PLATFORM}/${PKG_MGR}.sh"
        if install_pkg_mgr; then
          append_config "PKG_MGR" "$PKG_MGR"
          return 0
        else
          return 1
        fi
        ;;
    esac
  done
}

source_config_file
