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
  utils.fwrite("Shocking '%s'...\n", package)
end

