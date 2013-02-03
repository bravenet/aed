package require Tcl 8.6
package require aed::module

package provide aed::modules::redis 2.4

namespace eval ::aed::modules::redis:: {
  ::aed::module create Common {
    -homepage "http://redis.io"
    -executable redis-server

    method post_install {variants} {
    }
  }
}

namespace eval ::aed::modules::redis::darwin::homebrew:: {
  ::aed::module create redis {
    superclass ::aed::modules::redis::Common

    -name redis24
    -version 2.4.17
  }
}
