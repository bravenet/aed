PKG_MGR_DESC="The missing package manager for OS X."
PKG_MGR_EXEC="brew"

pkg_mgr_install() {
  debug "Running '$PKG_MGR_EXEC install $1'"
  ${PKG_MGR_EXEC} install $1
}

pkg_mgr_check() {
  debug "Running '$PKG_MGR_EXEC list $1'"
  ${PKG_MGR_EXEC} list ${1}
}

has_pkg_mgr() {
  debug "checking for '${PKG_MGR_EXEC}' command"
  has_cmd "${PKG_MGR_EXEC}"
}

install_pkg_mgr() {
  ruby -e "$(curl -fsSkL raw.github.com/mxcl/homebrew/go)"
  if ! brew doctor; then
    die "Please resolve your homebrew issues before continuing."
  fi
}

update_pkg_mgr() {
  brew update
}
