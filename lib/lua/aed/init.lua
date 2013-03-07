local utils = require 'aed.utils'
local core = require 'aed.core'

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

print (argv)

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
