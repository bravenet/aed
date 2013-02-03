package provide aed::defib 1.0

namespace eval ::aed::defib:: {
  namespace export install post_install versions
  namespace ensemble create

  variable ModulesCommands
  variable DefaultVariants
  set DefaultVariants { -devel -server -client }
}

proc ::aed::defib::versions {module} {
  ::aed::inform [package versions [ModuleNamespace $module]]
}

proc ::aed::defib::install {module args} {
  # pre-process the arguments
  set processed_ [ProcessArgs {*}$args]

  # pull out the variant list and post_install options
  set version [dict get $processed_ version]
  set variants [dict get $processed_ variants]
  set perform_post [dict get $processed_ post_install]

  # load the module
  set module_object [LoadModule $module $version]

  PerformInstall $module_object $variants $perform_post
}

proc ::aed::defib::post_install {module args} {
  # pre-process the arguments
  set processed_ [ProcessArgs {*}$args]

  # pull out the variant list and post_install options
  set version [dict get $processed_ version]
  set variants [dict get $processed_ variants]

  # load the module
  set module_object [LoadModule $module $version]

  PerformPostInstall $module_object $variants
}

proc ::aed::defib::ProcessArgs {{version 0-} args} {
  variable DefaultVariants

  set flags [lrange $DefaultVariants 0 end]
  set post_install on

  if {[regexp {^[+-]} $version]} {
    set args [linsert $args 0 $version]
  }

  foreach arg $args {
    switch -exact -- $arg {
      -devel -
      -server -
      -client {
        set pos [lsearch -exact $flags $arg]
        if {$pos != -1} {
          set flags [lreplace $flags $pos $pos]
        }
      }
      -post_install {
        set post_install off
      }
    }
  }

  return [dict create version $version variants $flags post_install $post_install]
}

proc ::aed::defib::ModuleNamespace {module} {
  return "aed::modules::${module}"
}

proc ::aed::defib::LoadModule {module version} {
  set platform [::aed platform]
  set package_manager [::aed::manager::current]

  # first try and load the module package
  set module_ns [join [list "aed::modules" $module] "::"]
  switch -regexp -- $version {
    {(.*)\-$} -
    {(.*)\-(.*)} {
      package require $module_ns $version
    }
    default {
      package require -exact $module_ns $version
    }
  }

  # now try and find the actual module class
  set module_manager_ns [join [list $module_ns $platform [$package_manager name]] "::"]
  set module_class [join [list $module_manager_ns $module] "::"]
  ::aed::debug "Attempt to load \"$module_class\""
  try {
    set instance [$module_class new $package_manager]
  } trap {NONE} {em opts} {
    set module_class [join [list $module_ns $module] "::"]
    ::aed::debug "Attempt to load \"$module_class\""
    try {
      set instance [$module_class new $package_manager]
    } trap {NONE} {
      ::aed::fatal "Could not load module '$module ($version)'"
    }
  }

  return $instance
}

proc ::aed::defib::PerformInstall {module variants perform_post} {
  set module_name [$module name]
  $module install $variants
  if {$perform_post} {
    PerformPostInstall $module $variants
  }
}

proc ::aed::defib::PerformPostInstall {module variants} {
  ::aed::inform "Running post_install for '[$module name]' ([$module version]) with variants: {$variants}..."
  $module post_install $variants
}


