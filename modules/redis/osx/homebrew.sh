module_pre_install() {
  debug "redis pre_install"
  missing_cmd "redis-server"
}

module_install() {
  debug "redis install"
  brew install redis
}

module_post_install() {
  debug "redis post_install"
}
