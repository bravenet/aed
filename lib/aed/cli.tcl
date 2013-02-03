package provide aed::cli 1.0

namespace eval ::aed::cli:: {
  namespace export process
  namespace ensemble create
}

proc ::aed::cli::process {} {
  global argv0 argc argv

  set options [dict create verbose off command {}]
  parse $argv options

  return $options
}

proc ::aed::cli::parse {argv optdict} {
  if {[llength $argv] == 0} {
    return
  }

  set arg [lindex $argv 0]
  switch -exact -- $arg {
    -v -
    --verbose {
      uplevel 1 [list dict set $optdict verbose on]
    }
    versions -
    install -
    post_install {
      uplevel 1 [list dict set $optdict command $argv]
      return
    }
  }

  tailcall parse [lreplace $argv 0 0] $optdict
}

proc ::aed::cli::exitWithUsage {} {
  global argv0

  ::aed::fatal "Usage: $argv0 \[command\] \[package\] \[package\]"
}
