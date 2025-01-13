local _version = "0.9.4"
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
smiti18n (pronouced smitten) is a powerful internationalization (i18n) library that helps you create multilingual applications in Lua and LÖVE.

Forked from i18n.lua by Enrique García Cota and includes new features and improvements.

It provides an intuitive API for managing translations, with support for:

- Variable interpolation in strings
- Pluralization rules for many languages
- Hierarchical organization of translations
- Multiple locale fallbacks
- Array-based translations
- File-based translation loading
- Seamless LÖVE game engine integration for filesystem paths

Requirements
- Lua 5.1-5.4 or LuaJIT 2.0-2.1
- LÖVE 11.0+ (optional)
  ]],
  labels = { "i18n", "love" },
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
