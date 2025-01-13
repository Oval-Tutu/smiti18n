# smiti18n

A very complete internationalization library for Lua with LÖVE support 🌕💕

[![Test 🧪](https://github.com/Oval-Tutu/smiti18n/actions/workflows/ci.yml/badge.svg)](https://github.com/Oval-Tutu/smiti18n/actions/workflows/ci.yml) [![Lua Versions](https://img.shields.io/badge/Lua-5.1%20%7C%205.2%20%7C%205.3%20%7C%205.4%20%7C%20JIT-blue)](https://github.com/Oval-Tutu/smiti18n) [![LuaRocks](https://img.shields.io/luarocks/v/flexiondotorg/smiti18n)](https://luarocks.org/modules/flexiondotorg/smiti18n) [![License](https://img.shields.io/github/license/Oval-Tutu/smiti18n)](https://github.com/Oval-Tutu/smiti18n/blob/master/LICENSE)

## Introduction

smiti18n (*pronouced smitten*) is a powerful internationalization (i18n) library that helps you create multilingual applications in Lua and [LÖVE](https://love2d.org/).

Forked from [i18n.lua](https://github.com/kikito/i18n.lua) by Enrique García Cota and includes new features and improvements.

It provides an intuitive API for managing translations, with support for:

- Variable interpolation in strings
- Pluralization rules for many languages
- Hierarchical organization of translations
- Multiple locale fallbacks
- Array-based translations
- File-based translation loading
- Seamless LÖVE game engine integration for filesystem paths

### Requirements
- Lua 5.1-5.4 or LuaJIT 2.0-2.1
- LÖVE 11.0+ (*optional*)

### Quick example

Here's a quick example:

```lua
i18n = require 'smiti18n'

-- Load some translations
i18n.load({
  en = {
    greeting = "Hello %{name}!",
    messages = {
      one = "You have one new message",
      other = "You have %{count} new messages"
    }
  },
  es = {
    greeting = "¡Hola %{name}!",
    messages = {
      one = "Tienes un mensaje nuevo",
      other = "Tienes %{count} mensajes nuevos"
    }
  }
})

-- Set the current locale
i18n.setLocale('es')

-- Use translations
print(i18n('greeting', {name = "Luna"}))     -- ¡Hola Luna!
print(i18n('messages', {count = 3}))         -- Tienes 3 mensajes nuevos
```

## Installation

### Using LuaRocks

[smiti18n is available on LuaRocks](https://luarocks.org/modules/flexiondotorg/smiti18n). You can install it with the following command:

```shell
luarocks install smiti18n
```

### Manual Installation

#### Option 1: Git Clone

Clone this repository and copy the `smiti18n` folder into your project as something like `lib/smiti18n`.

```shell
git clone https://github.com/Oval-Tutu/smiti18n.git
cd smiti18n
cp -r smiti18n your-project/lib/
```

#### Option 2: Download Release

1. Download latest release from [Releases](https://github.com/Oval-Tutu/smiti18n/releases)
2. Extract the archive
3. Copy `smiti18n` directory to your project

Project structure after installation:

```
your-project/
  ├── lib/
  │   └── smiti18n/
  │       ├── init.lua
  │       ├── interpolate.lua
  │       ├── plural.lua
  │       ├── variants.lua
  │       └── version.lua
  └── main.lua
```

#### Using the Library

```lua
-- Require smiti18n in your code
local i18n = require 'lib.smiti18n'
```

### Translation Files

smiti18n supports both single-file and multi-file approaches for managing translations.

#### Single File

Store all translations in one file (e.g., `translations.lua`):

```lua
-- translations.lua
return {
  en = {
    greeting = "Hello!",
    messages = {
      one = "You have one message",
      other = "You have %{count} messages"
    }
  },
  es = {
    greeting = "¡Hola!",
    messages = {
      one = "Tienes un mensaje",
      other = "Tienes %{count} mensajes"
    }
  }
}

-- Load translations
i18n.loadFile('translations.lua')
```

#### Multiple Files

Organize translations by language (recommended for larger projects):

Here's an example project structure:

```
i18n/
  ├── en.lua   -- English translations
  ├── es.lua   -- Spanish translations
  └── fr.lua   -- French translations
```

**`en.lua`**
```lua
return {
  en = {  -- Locale key required
    greeting = "Hello!",
    messages = {
      one = "You have one message",
      other = "You have %{count} messages"
    }
  }
}
```

```lua
…
i18n.loadFile('i18n/en.lua') -- English translation
i18n.loadFile('i18n/es.lua') -- Spanish translation
i18n.loadFile('i18n/fr.lua') -- French translation
…
```

#### Key Points
- Files must include locale key in returned table
- Can be loaded in any order
- Later loads override earlier translations

### Locales and Fallbacks

smiti18n provides flexible locale support with automatic fallbacks and regional variants.

#### Locale Naming

- Pattern: `language-REGION` (e.g., 'en-US', 'es-MX', 'pt-BR')
- Separator: hyphen (-) only
- Not supported: underscores, spaces, or other separators

#### Fallback Chain

smiti18n implements a robust fallback system:

1. **Current Locale** ('es-MX')
2. **Parent Locales** (if defined, e.g., 'es-419')
3. **Root Locale** ('es')
4. **Default Value** (if provided)
5. **nil** (if no matches found)

```lua
-- Example showing fallback chain
i18n.load({
  es = {
    greeting = "¡Hola!",
  },
  ["es-MX"] = {
    farewell = "¡Adiós!"
  }
})

i18n.setLocale('es-MX')
print(i18n('farewell'))                -- "¡Adiós!"    (from es-MX)
print(i18n('greeting'))                -- "¡Hola!"     (from es)
print(i18n('missing'))                 -- nil          (not found)
print(i18n('missing', {
    default = 'Not found'
}))                                    -- "Not found"   (default value)
```

#### Multiple Locales

For handling regional variants, you can specify multiple locales in order of preference:

```lua
i18n.load({
  ['es-419'] = { cookie = 'galleta' },    -- Latin American
  ['es-ES']  = { cookie = 'galletita' },  -- European
  ['es']     = { thanks = 'gracias' }     -- Generic
})

-- Set multiple locales in priority order
i18n.setLocale({'es-419', 'es-ES', 'es'})

i18n('cookie')  -- Returns 'galleta' (from es-419)
i18n('thanks')  -- Returns 'gracias' (from es)
```

Key benefits of multiple locales:
- Handle regional variations (e.g., pt-BR vs pt-PT)
- Share base translations across regions
- Create fallback chains (e.g., es-MX → es-419 → es)
- Support partial translations with automatic fallback

**💡NOTE!** Locales are tried in order of preference, with duplicates automatically removed.

### String Interpolation

smiti18n supports three different styles of variable interpolation:

#### Named Variables (*Recommended*)

Named variables are the recommended approach as they make translations more maintainable and less error-prone.

```lua
i18n.set('greeting', 'Hello %{name}, you are %{age} years old')
i18n('greeting', {name = 'Alice', age = 25})  -- Hello Alice, you are 25 years old
```
#### Lua Format Specifiers
```lua
i18n.set('stats', 'Score: %d, Player: %s')
i18n('stats', {1000, 'Bob'})  -- Score: 1000, Player: Bob
```
#### Advanced Formatting
```lua
i18n.set('profile', 'User: %<name>.q | Age: %<age>.d | Level: %<level>.o')
i18n('profile', {
    name = 'Charlie',
    age = 30,
    level = 15
})  -- User: Charlie | Age: 30 | Level: 17k
```

Format modifiers:
- `.q`: Quotes the value
- `.d`: Decimal format
- `.o`: Ordinal format

### Pluralization

smiti18n implements the [CLDR plural rules](http://cldr.unicode.org/index/cldr-spec/plural-rules) for accurate pluralization across different languages. Each language can have different plural categories like 'one', 'few', 'many', and 'other'.

#### Basic Usage
```lua
i18n = require 'smiti18n'

i18n.load({
  en = {
    msg = {
      one   = "one message",
      other = "%{count} messages"
    }
  },
  ru = {
    msg = {
      one   = "1 сообщение",
      few   = "%{count} сообщения",  -- 2-4 messages
      many  = "%{count} сообщений",  -- 5-20 messages
      other = "%{count} сообщения"   -- fallback
    }
  }
})

-- English pluralization
i18n.setLocale('en')
print(i18n('msg', {count = 1}))  -- "one message"
print(i18n('msg', {count = 5}))  -- "5 messages"

-- Russian pluralization
i18n.setLocale('ru')
print(i18n('msg', {count = 1}))  -- "1 сообщение"
print(i18n('msg', {count = 3}))  -- "3 сообщения"
print(i18n('msg', {count = 5}))  -- "5 сообщений"
```

**💡NOTE!** The `count` parameter is required for plural translations.

#### Custom Pluralization Rules

For special cases or invented languages, you can define custom pluralization rules by specifying a custom pluralization function in the second parameter of `setLocale()`.

```lua
-- Custom pluralization for a constructed language
local customPlural = function(n)
  if n == 0 then return 'zero' end
  if n == 1 then return 'one' end
  if n > 1000 then return 'many' end
  return 'other'
end

i18n.setLocale('conlang', customPlural)
```

This function must return a plural category when given a number.
Available plural categories:
- `zero`: For languages with special handling of zero
- `one`: Singular form
- `two`: Special form for two items
- `few`: For languages with special handling of small numbers
- `many`: For languages with special handling of large numbers
- `other`: Default fallback form

### Arrays

Translation values can be arrays for handling ordered collections of strings with support for interpolation and pluralization.

```lua
i18n.load({
  en = {
    -- Simple array of strings
    greetings = {"Hello!", "Hi there!", "Howdy!"},

    -- Get a random greeting
    print(i18n('greetings')[math.random(#i18n('greetings'))])
  }
})
```

#### Features

Arrays support:

- Plain strings
- Interpolated values
- Plural forms
- Nested arrays
- Mixed content types

#### Common Use Cases

1. **Dialogue Systems**
```lua
i18n.load({
  en = {
    dialogue = {
      "Detective: What brings you here?",
      "Witness: I saw everything %{time}.",
      {
        one = "Detective: Just %{count} witness?",
        other = "Detective: Already %{count} witnesses."
      }
    }
  }
})

-- Play through dialogue sequence
for _, line in ipairs(i18n('dialogue', {time = "last night", count = 1})) do
  print(line)
end
```

2. **Tutorial Steps**

```lua
i18n.load({
  en = {
    tutorial = {
      "Welcome to %{game_name}!",
      {
        one = "You have %{lives} life - be careful!",
        other = "You have %{lives} lives remaining."
      },
      "Use WASD to move",
      "Press SPACE to jump"
    }
  }
})
```

3. **Status Displays**

```lua
i18n.load({
  en = {
    status = {
      "=== Game Status ===",
      "Player: %{name}",
      {
        one = "%{coins} coin collected",
        other = "%{coins} coins collected"
      },
      "Level: %{level}",
      "=================="
    }
  }
})
```

#### Tips
- Arrays maintain their order
- Access individual elements with numeric indices
- Use `#` operator to get array length
- Combine with `math.random()` for random selection
- Arrays can be nested for complex dialogue trees

## Contributing

Contributions are welcome! Please feel free to submit a pull request.

## Specs

This project uses [busted](https://github.com/Olivine-Labs/busted) for its specs. If you want to run the specs, you will have to install it first. Then just execute the following from the root inspect folder:

```shell
busted
```
