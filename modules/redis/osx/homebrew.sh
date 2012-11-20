# these two variables are package manager dependent
$PACKAGE_EXEC='redis-server'
$PACKAGE_NAME='redis'

if [ has_cmd $PACKAGE_EXEC ]; then
  exit $SKIP
fi

if [ has_cmd `$PKG_MGR --prefix`/bin/$PACKAGE_EXEC ]; then
  # maybe repair the path
  exit $ERROR
fi

if [ ! $PKG_MGR list $PACKAGE_NAME ]; then
  $PKG_MGR install $PACKAGE_NAME
else
  $PKG_MGR link $PACKAGE_NAME
fi
