require 'utils'

function header ()
  print [[
                   ______  _____
            /\    |  ____||  __ \
           /  \   | |__   | |  | |
          / /\ \  |  __|  | |  | |
         / ____ \ | |____ | |__| |
        /_/    \_\|______||_____/


            Automated External
              Defibrillator
  ]]
end

function getconf (pwd)
  local base_dir = os.getenv('AED_BASE')
  local local_dir = pwd .. "/.aed"
  local home_dir = os.getenv('HOME')

  return {
    base_dir = base_dir,
    local_dir = local_dir,

    rc = home_dir .. "/.aedrc",

    base_mods = base_dir .. "/modules",
    local_mods = local_dir .. "/modules",

    aedfile = pwd .. "/Aedfile"
  }
end

function defib (module)
  local package = module
  local options = {}

  if type(module) == 'table' then
    if type(module[1]) ~= 'string' then
      error("no module specified")
    end

    package = table.remove(module, 0)
    options = module
  elseif type(module) ~= 'string' then
    error("no module specified")
  end

  _defib(package, options)
end

function _defib (package, options)
  fwrite("Shocking '%s'...\n", package)
end

function main (pwd)
  AED_CFG = getconf(pwd)

  header()

  local ops, err = loadfile(AED_CFG.aedfile)
  if (ops == nil) then
    print(err)
    os.exit(1)
  end

  ops()
end
