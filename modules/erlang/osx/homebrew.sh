#PKG_NAME="mongodb"
#PKG_EXEC="mongod"
pkg_mgr exists erlang && exit $SKIP
pkg_mgr install erlang
