package require Tcl 8.6
package provide aed::module 1.0

namespace eval ::aed::module:: {
  namespace export create
  namespace ensemble create
}

proc ::aed::module::create {name spec} {
  tailcall ::aed::module::ModuleMetaClass create $name $spec
}

namespace eval ::aed::module:: {

  # A base module class that provides the just the shell. All classes created
  # through the module meta-class will inherit from this automatically.

  oo::class create Base {
    variable Installer
    variable name
    variable variants

    constructor {installer} {
      my variable Installer name variants

      set Installer $installer
      if {![info exists name]} {
        set name [namespace tail [info object class [self]]]
      } else {
        set name [my name]
      }

      if {![info exists variants]} {
        set variant_list [list -devel $name -client $name -server $name]
        set variants [dict create {*}$variant_list]
      }
    }

    method name {} {
      my variable name
      return $name
    }

    method variants {} {
      my variable variants
      return $variants
    }

    method installed? {files} {
      my variable Installer
      foreach filename $files {
        if {![$Installer installed? $filename]} {
          return 0
        }
      }
      return 1
    }

    method installer {} {
      my variable Installer
      return $Installer
    }

    method install {desired} {
      ::aed::inform -continues "Shocking '[my name]' ([my version]) with variants: {$desired}... "

      # fetch all known packages
      set packages [dict create {*}[my variants]]

      # fetch all known files to check for and filter them
      set files [dict create {*}[my files]]
      set files [dict filter $files key {*}$desired]

      # if all files for a variant are present we can skip it
      set variants [dict create]
      dict for {variant fileList} $files {
        set package_name [dict get $packages $variant]
        if {![my installed? $fileList]} {
          dict set variants $package_name true
        }
      }

      if {[dict size $variants] > 0} {
        # finally install all the packages
        set installer [my installer]
        dict for {package_name _} $variants {
          ::aed::debug "installing '$package_name'..."
          $installer install $package_name
        }
      }
      ::aed::inform "done."
    }

    method post_install {desired_variants} {
      error "not implemented"
    }
  }

  # The AttrMixin class is inspired by oo::Slot. It is constructed
  # along side a module class as a temporary storage for variables
  # described using the `-varName value` syntax. Once the module class
  # has been defined, the Apply method is called to add all the variable
  # declarations, declare a module specific mixin and mix that in.

  oo::class create AttrMixin {
    # a simple dictionary to store all the variables
    variable variables

    constructor {} {
      set variables [dict create]
    }

    method get {varname} {
      return [set [my varname $varname]]
    }

    method set {varname value} {
      if {[dict exists $variables $varname]} {
        set existing [dict get $variables $varname]
        try {
          # ugly hack to check if we're dealing with nested dictionaries
          dict size $existing

          set value [dict create {*}$value]
        }
      }

      return [dict set variables $varname $value]
    }

    method Apply {class} {
      # append variable declarations to the class
      set vars [dict keys $variables]
      ::oo::define $class variable -append {*}$vars
      
      # construct a constructor body for our mixin
      set body {}
      lappend body [subst {my variable {*}$vars}]

      foreach var $vars {
        # append initializer code to the constructor body
        lappend body [list set $var [dict get $variables $var]]

        # directly create an accessor method
        ::oo::define $class method $var {} [subst {
          my variable $var
          return \$$var
        }]
      }
      lappend body { next {*}$args }
      set body [join $body "\n"]

      # to prevserve any pre-existing constructors, create a new
      # class to contain the constructor and mix it in
      set mixin [::oo::class create ${class}.AttrMixin]
      ::oo::define $mixin constructor {args} $body

      # finally mix it into the class itself
      ::oo::define $class mixin -append $mixin
    }
  }

  # The module meta-class is responsible for constructing module classes.

  oo::class create ModuleMetaClass {
    superclass oo::class

    self {
      method create {name spec} {
        # create the a bare class and a paired AttrMixin instance
        set cls [next $name]
        set vars [::aed::module::AttrMixin new]

        # capture the bare class unique namespace
        set clsns [info object namespace $cls]

        # open up the unique class namespace and store reference to the
        # AttrMixin instance and create a proc command to forward commands
        # onto the AttrMixin instance.
        #
        # This is similar to the `my` construct already present in TclOO.
        namespace eval $clsns [list variable MyAttrMixin $vars]
        namespace eval $clsns {
          proc AttrMixin {args} {
            variable MyAttrMixin
            tailcall $MyAttrMixin {*}$args
          }
        }

        set oldHandler [namespace eval ::oo::define {namespace unknown}]
        namespace eval ::oo::define { namespace unknown ::aed::module::AttrHandler }
        try {
          # finally use the given class spec to define the class
          ::oo::define $cls $spec
        } finally {
          namespace eval ::oo::define { namespace unknown oldHandler }
        }


        # export our hidden Apply method and apply the vars to the class
        oo::objdefine $vars export Apply
        $vars Apply $cls
        $vars destroy

        # remove the AttrMixin variable and proc from the classes
        # unique namespace
        namespace eval $clsns {
          unset MyAttrMixin
          rename AttrMixin ""
        }

        oo::define $cls superclass -append ::aed::module::Base
      }
    }
  }
}

namespace eval ::aed::module:: {

  # hold on to a referene to the ::oo::define namespace unknown handler
  variable TclOOUnknownHandler [namespace eval ::oo::define {namespace unknown} ]
}

# a proc that will be dynamically registered as the unknown handler inside the
# ::oo::define namespace, but only when classes are created using the
# ModuleMetaClass class

proc ::aed::module::AttrHandler {args} {
  set arg1 [lindex $args 0]

  # handle methods prefixed with '-' differently
  if [regexp {^-(.*)$} $arg1 -> varname] {
    # find out the class name
    set cls [lindex [info level -1] 1]

    # target the AttrMixin instance and set the varname
    tailcall [info object namespace $cls]::AttrMixin set $varname [lindex $args 1]
  } else {
    # FIXME: is there a better way to call the original
    variable TclOOUnknownHandler
    tailcall $TclOOUnknownHandler {*}$args
  }
}

