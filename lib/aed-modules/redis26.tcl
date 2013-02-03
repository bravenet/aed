package require Tcl 8.6
package require aed::module

package provide aed::modules::redis 2.6

namespace eval ::aed::modules::redis:: {
  ::aed::module create Common {
    -homepage "http://redis.io"
    -files {
      -client redis-cli
       -server redis-server
       -devel {}
    }

    method post_install {variants} {
    }
  }
}

namespace eval ::aed::modules::redis::darwin::homebrew:: {
  ::aed::module create redis {
    superclass ::aed::modules::redis::Common

    -version 2.6.7
  }
}
