package require aed::cli 1.0
package require aed::defib 1.0
package require aed::module 1.0
package require aed::manager 1.0
package require aed::managers 1.0

package provide aed 1.0

namespace eval ::aed:: {
  namespace export *
  namespace ensemble create

  variable MsgLevel
  variable HasStarted false
  variable VerboseMode off
  variable CmdOptions
}

proc ::aed::platform {} {
  global tcl_platform
  return [string tolower $tcl_platform(os)]
}

proc ::aed::machine {} {
  global tcl_platform
  return [string tolower $tcl_platform(machine)]
}

proc ::aed::startup {} {
  variable HasStarted
  variable VerboseMode
  variable CmdOptions

  if {$HasStarted} {
    ::aed::fatal "Already Started"
  } else {
    set HasStarted true
  }

  set CmdOptions [::aed::cli process]
  set VerboseMode [dict get $CmdOptions verbose]

  ::aed::manager detect

  set command [dict get $CmdOptions command]
  if {$command == {}} {
    namespace eval ::aed {
      # TODO source in the Aedfile
      debug "Sourcing Aedfile..."
      source "./Aedfile"
    }
  } else {
    ::aed::defib {*}$command
  }
}

proc ::aed::fatal {args} {
  ::aed::puts {*}$args
  exit 1
}

proc ::aed::warn {args} {
  ::aed::puts {*}$args
}

proc ::aed::debug {args} {
  variable VerboseMode
  if {$VerboseMode} {
    ::aed::puts {*}$args
  }
}

proc ::aed::inform {args} {
  ::aed::puts {*}$args
}

proc ::aed::puts {args} {
  variable MsgLevel

  switch -- [llength $args] {
    1 {
      lassign $args msg
    }
    2 {
      lassign $args -continues msg
    }
    default {
      error "wrong # args: should be \"[lindex [info level 0] 0] ?-continues? string\""
    }
  }

  set continuation false
  set caller [namespace tail [lindex [info level -1] 0]]
  if {[info exists MsgLevel] && $MsgLevel eq $caller} {
    unset MsgLevel
    set continuation true
  }

  switch -exact -- $caller {
    fatal -
    warn {
      set channel stderr
    }
    debug {
      set channel stdout
      if {!$continuation} {
        set msg "  -- ${msg}"
      }
    }
    default {
      set channel stdout
    }
  }

  if {!$continuation && [info exists MsgLevel]} {
    ::puts $channel ""
  }

  set outargs {}
  if {[info exists -continues] && ${-continues} eq "-continues"} {
    set MsgLevel $caller
    lappend outargs -nonewline
  }
  lappend outargs $channel $msg

  ::puts {*}$outargs
}
