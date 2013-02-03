package provide aed::manager 1.0
package require Tcl 8.6

namespace eval ::aed::manager:: {
  namespace export detect instance
  namespace ensemble create

  variable PackageManager
  set PackageManager 0
}

proc ::aed::manager::detect {} {
  variable PackageManager

  ::aed::inform -continues "Searching for package manager..."

  set available [info commands ::aed::managers::[::aed::platform]::*]
  foreach manager $available {
    set instance [$manager new]
    set cmd [$instance command]
    if {[$instance installed? $cmd]} {
      set PackageManager $instance
      ::aed::inform "found [$instance name]."
      return
    }
  }

  ::aed::fatal "No package managers detected"
}

proc ::aed::manager::current {} {
  variable PackageManager
  if {$PackageManager == 0} {
    ::aed::manager detect
  }

  return $PackageManager
}

namespace eval ::aed::manager:: {

  ::oo::class create Base {
    variable Command

    constructor {command} {
      my variable Command
      set Command $command
    }

    method name {} {
      return [namespace tail [info object class [self]]]
    }

    method command {} {
      my variable Command
      return $Command
    }

    method command_path {} {
      return [file join [my bin_path] [my command]]]
    }

    method path {} {
      error "must be implemented in sub-class"
    }

    method bin_path {} {
      return [file join [my path] bin]
    }

    method sbin_path {} {
      return [file join [my path] sbin]
    }

    method lib_path {} {
      return [file join [my path] lib]
    }

    method install {package_name} {
      error "must be implemented in sub-class"
    }

    method installed? {executable} {
      set locations [list "" [my bin_path] [my sbin_path]]
      foreach location $locations {
        set full_path [file join $location $executable]
        ::aed::debug -continues "looking for '$full_path'... "
        if {[my type? $full_path]} {
          ::aed::debug "found."
          return true
        } else {
          ::aed::debug "not found."
        }
      }

      return false
    }

    method type? {executable} {
      # look for it on the path
      return [expr {[catch {exec type $executable}] == 0}]
    }
  }

}
