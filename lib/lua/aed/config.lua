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
