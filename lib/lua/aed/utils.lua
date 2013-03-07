local M = {}
local V = setmetatable({}, {__index = M})

local io = require 'io'
local string = require 'string'

function M.fwrite(fmt, ...)
  return io.write(string.format(fmt, ...))
end

return M
