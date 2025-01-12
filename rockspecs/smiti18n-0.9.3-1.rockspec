local _version = "0.9.3"
local _revision = "1"

package = "smiti18n"
version = _version .. "-" .. _revision
source = {
  url = ("https://github.com/Oval-Tutu/smiti18n/archive/v%s.tar.gz"):format(_version),
  dir = ("smiti18n-%s"):format(_version)
}
description = {
  summary = "A very complete internationalization library for Lua with LÖVE support",
  detailed = [[
    smiti18n is a full-featured i18n library for Lua with LÖVE integration.
    It handles hierarchies of tags, accepts entries in several ways (one by one,
    in a table or in a file), and implements extensive pluralization rules,
    fallbacks, arrays, and multiple locale support.
  ]],
  homepage = "https://github.com/Oval-Tutu/smiti18n",
  license = "MIT"
}
dependencies = {
  "lua >= 5.1"
}
build = {
  type = "builtin",
  modules = {
    ["smiti18n.init"]         = "smiti18n/init.lua",
    ["smiti18n.plural"]       = "smiti18n/plural.lua",
    ["smiti18n.variants"]     = "smiti18n/variants.lua",
    ["smiti18n.interpolate"]  = "smiti18n/interpolate.lua"
  }
}
