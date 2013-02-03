package require Tcl 8.6
package require aed::module

package provide aed::modules::mysql 5.1

namespace eval ::aed::modules::mysql:: {
  ::aed::module create Common {

    -homepage "http://dev.mysql.com/doc/refman/5.5/en"
    -executable mysqld

    method post_install {variants} {
      puts "doing core mysql post_install"

      puts "was installed to [file join [[my installer] bin_path] [my executable]]"
    }
  }
}

namespace eval ::aed::modules::mysql::darwin::homebrew:: {
  ::aed::module create mysql {
    superclass ::aed::modules::mysql::Common

    -name mysql51
    -version 5.1.65

    -variants {
      -server mysql-server
      -devel mysql-devel
      -client mysql-client
    }
  }
}

namespace eval ::aed::modules::mysql::darwin::macports:: {
  ::aed::module create macports {
    superclass ::aed::modules::mysql::Common

    -version 5.1.65

    -variants {
      -server mysql-server
      -devel mysql-devel
      -client mysql
    }
  }
}
