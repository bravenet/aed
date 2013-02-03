package provide aed::managers::darwin::macports 1.0

package require Tcl 8.6
package require aed::manager

namespace eval ::aed::managers::darwin:: {
  ::oo::class create macports {
    superclass ::aed::manager::Base

    constructor {} { next port }

    method path {} {
      return [file join /opt local]
    }

    method install {package_name} {
      set cmd "[my command] install $package_name"
      exec {*}$cmd
    }
  }
}
