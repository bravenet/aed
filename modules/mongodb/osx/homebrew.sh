#PKG_NAME="mongodb"
#PKG_EXEC="mongod"
pkg_mgr exists mongodb && exit $SKIP
pkg_mgr install mongodb
