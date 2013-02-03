package provide aed::managers::darwin::homebrew 1.0

package require Tcl 8.6
package require aed::manager

namespace eval ::aed::managers::darwin:: {
  ::oo::class create homebrew {
    superclass ::aed::manager::Base

    constructor {} { next brew }

    method path {} {
      return [file join /usr local]
    }

    method install {package_name} {
      set cmd "[my command] install $package_name"
      exec {*}$cmd
    }
  }
}
