local aed_root = os.getenv('AED_ROOT') or (os.getenv('HOME') .. "/.aed")
local aed_libs = table.concat({
  aed_root .. "/lib/lua/?.lua",
  aed_root .. "/lib/lua/?/init.lua",
}, ';')


print ("original path")
print (package.path)

package.path = aed_libs .. package.path

print ("modified path")
print (package.path)

local utils = require 'aed.utils'
local lfs = require 'lfs'

local pwd = lfs.currentdir()
utils.fwrite("Hello there inside %s!!\n", pwd)
