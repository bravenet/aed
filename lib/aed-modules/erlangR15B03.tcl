package require Tcl 8.6
package require aed::module

package provide aed::modules::erlang 15.03

namespace eval ::aed::modules::erlang:: {
  ::aed::module create Common {
    -homepage "http://erlang.org"
    -files {
      -devel erl
    }

    method checkVersion {} {
      set cmd [file join [[my installer] bin_path] erl]
      try {
        set result [exec $cmd +V]
        set status 0
      } trap CHILDSTATUS {results options} {
        set status [lindex [dict get $options -errorcode] 2]
      }

      if {$status != 0} {
        return 0
      }

      return [string match {^(?:(\d+)\.)?(?:(\d+)\.)?(\*|\d+)$} $result]
    }
  }
}

namespace eval ::aed::modules::erlang::darwin::homebrew:: {
  ::aed::module create erlang {
    superclass ::aed::modules::erlang::Common

    -version 5.9.3.1

    -variants {
      -devel erlang
    }
  }
}
