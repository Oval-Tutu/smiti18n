local _version = "0.9.4"
local _revision = "1"

rockspec_format = "3.0"
package = "smiti18n"
version = _version .. "-" .. _revision
source = {
  url = ("https://github.com/Oval-Tutu/smiti18n/archive/%s.tar.gz"):format(_version),
  dir = ("smiti18n-%s"):format(_version)
}
description = {
  summary = "A very complete internationalization library for Lua with LÖVE support",
  detailed = [[
smiti18n (pronounced smitten) is a powerful internationalization (i18n) library that helps you create multilingual applications in Lua and LÖVE.

**Core Features:**
- Smart file-based loading & fallbacks
- Rich text interpolation & pluralization
- Locale-aware formatting for numbers, dates and currency
- Built for LÖVE game engine

**Rich Game Content:**
- Complex dialogue support:
  - Branching conversations
  - Character-specific translations
  - Context-aware responses
- 53 locales, 650+ game-specific phrases
- 36 regional number formats

An intuitive API for managing translations forked from i18n.lua by Enrique García Cota incorporating a collection of community contributions.
The number, date and time formatting has been ported from Babel.
Includes translations from PolyglotGamedev.
Significantly expanded test coverage and documentation.

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
    ["smiti18n.format"]       = "smiti18n/format.lua",
    ["smiti18n.init"]         = "smiti18n/init.lua",
    ["smiti18n.interpolate"]  = "smiti18n/interpolate.lua",
    ["smiti18n.plural"]       = "smiti18n/plural.lua",
    ["smiti18n.variants"]     = "smiti18n/variants.lua"
  },
  copy_directories = {
    "locales"
  }
}
