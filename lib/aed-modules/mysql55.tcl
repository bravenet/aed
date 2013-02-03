package require Tcl 8.6
package require aed::module

package provide aed::modules::mysql 5.5

namespace eval ::aed::modules::mysql:: {
  ::aed::module create Common {

    -homepage "http://dev.mysql.com/doc/refman/5.5/en"

    -files {
      -server mysqld
      -client mysql
      -devel { mysql.h my_config.h }
    }

    method checkVersion {} {
      set cmd [file join [[my installer] bin_path] mysql_config]
      try {
        set result [exec $cmd --version]
        set status 0
      } trap CHILDSTATUS {results options} {
        set status [lindex [dict get $options -errorcode] 2]
      }

      if {$status != 0} {
        return 0
      }

      return [string first 5.5 $result]
    }

    method post_install {variants} {
      puts "doing core mysql post_intall"

      puts "was installed to [file join [[my installer] bin_path] [my executable]]"
    }
  }
}

namespace eval ::aed::modules::mysql::darwin::homebrew:: {
  ::aed::module create mysql {
    superclass ::aed::modules::mysql::Common

    -version 5.5.28

    -variants {
      -server mysql
      -devel mysql
      -client mysql
    }
  }
}

namespace eval ::aed::modules::mysql::darwin::macports:: {
  ::aed::module create mysql {
    superclass ::aed::modules::mysql::Common

    -version 5.5.22

    -variants {
      -server mysql-server
      -devel mysql-devel
      -client mysql
    }
  }
}
