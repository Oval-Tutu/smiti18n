smiti18n.lua
============

smiti18n, (*pronouced smitten*), is a very complete i18n library for LÖVE and Lua 💕🌕
Forked from [i18n.lua](https://github.com/kikito/i18n.lua)

Description
===========

``` lua
i18n = require 'smiti18n'

-- loading stuff
i18n.set('en.welcome', 'welcome to this program')
i18n.load({
  en = {
    good_bye = "good-bye!",
    age_msg = "your age is %{age}.",
    phone_msg = {
      one = "you have one new message.",
      other = "you have %{count} new messages."
    }
  }
})
i18n.loadFile('path/to/your/project/i18n/de.lua') -- load German language file
i18n.loadFile('path/to/your/project/i18n/fr.lua') -- load French language file
…         -- section 'using language files' below describes structure of files

-- setting the translation context
i18n.setLocale('en') -- English is the default locale anyway

-- getting translations
i18n.translate('welcome') -- Welcome to this program
i18n('welcome') -- Welcome to this program
i18n('age_msg', {age = 18}) -- Your age is 18.
i18n('phone_msg', {count = 1}) -- You have one new message.
i18n('phone_msg', {count = 2}) -- You have 2 new messages.
i18n('good_bye') -- Good-bye!

```

Interpolation
=============

You can interpolate variables in 3 different ways:

``` lua
-- the most usual one
i18n.set('variables', 'Interpolating variables: %{name} %{age}')
i18n('variables', {name='john', age=10}) -- Interpolating variables: john 10

i18n.set('lua', 'Traditional Lua way: %d %s')
i18n('lua', {1, 'message'}) -- Traditional Lua way: 1 message

i18n.set('combined', 'Combined: %<name>.q %<age>.d %<age>.o')
i18n('combined', {name='john', age=10}) -- Combined: john 10 12k
```

Pluralization
=============

This lib implements the [unicode.org plural rules](http://cldr.unicode.org/index/cldr-spec/plural-rules). Just set the locale you want to use and it will deduce the appropriate pluralization rules:

``` lua
i18n = require 'i18n'

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
      few   = "%{count} сообщения",
      many  = "%{count} сообщений",
      other = "%{count} сообщения"
    }
  }
})

i18n('msg', {count = 1}) -- one message
i18n.setLocale('ru')
i18n('msg', {count = 5}) -- 5 сообщений
```

The appropriate rule is chosen by finding the 'root' of the locale used: for example if the current locale is 'fr-CA', the 'fr' rules will be applied.

If the provided functions are not enough (i.e. invented languages) it's possible to specify a custom pluralization function in the second parameter of setLocale. This function must return 'one', 'few', 'other', etc given a number.

Arrays
======

Translation values can be arrays containing strings, interpolated values, and plural forms:

```lua
i18n.load({
  en = {
    -- Simple array of strings
    greetings = {"Hello!", "Hi there!", "Howdy!"},

    -- Arrays with interpolation
    welcome = {
      "Welcome to %{game_name}!",
      "Player: %{player_name}",
      "Level: %{level}"
    },

    -- Arrays with plural forms
    status = {
      "Game Status:",
      {
        one = "%{count} player online",
        other = "%{count} players online"
      },
      {
        one = "%{lives} life remaining",
        other = "%{lives} lives remaining"
      }
    }
  }
})

-- Usage
i18n.setLocale('en')
i18n('greetings')  -- Returns: {"Hello!", "Hi there!", "Howdy!"}

i18n('welcome', {
  game_name = "Adventure Time",
  player_name = "Jake",
  level = 5
}) -- Returns interpolated array

i18n('status', {
  count = 3,
  lives = 1
}) -- Returns array with pluralized elements
```

Arrays maintain their order and can mix plain strings, interpolated values, and plural forms in any combination.
This is particularly useful for:

- Random message selection
- Dialogue sequences
- Multi-line status displays
- Ordered game tutorials

Fallbacks
=========

When a value is not found, the lib has several fallback mechanisms:
- If the value doesn't exist with the full locale name (e.g. 'es-ES'), it will try with just the root part ('es')
- If the locale has a 'parent' (e.g. es is the parent of 'es-MX'), the parent is tried
- If no parents are found, and a 'default' parameter is passed, return it:

```lua
i18n('msg', {default = 'Not translated'})                   -- 'Not translated'
i18n('msg', {default = 'Hello, %{name}!', name = 'Player'}) -- 'Hello, Player!'
```

- Otherwise the translation will return nil.

The parents of a locale are found by splitting the locale by its hyphens. Other separation characters (spaces, underscores, etc) are not supported.

Multiple Locales
================

You can also pass a list of locales to `setLocale` to provide multiple options before the fallback locale is used.
You can specify multiple locales in order of preference.
This is useful for handling regional variants of languages:

```lua
-- Set multiple locales in priority order
i18n.setLocale({'es-419', 'es-ES', 'es'})

-- Translations will be looked up in this order:
-- 1. Latin American Spanish (es-419)
-- 2. European Spanish (es-ES)
-- 3. Generic Spanish (es)
-- 4. Default fallback locale

-- Example translation table
i18n.load({
  ['es-419'] = {
    greeting = '¡Hola!',
    cookie = 'galleta'
  },
  ['es-ES'] = {
    greeting = '¡Hola!',
    cookie = 'galletita'
  },
  ['es'] = {
    greeting = '¡Hola!',
    thanks = 'gracias'
  }
})

i18n('cookie')  -- Returns 'galleta' (found in es-419)
i18n('thanks')  -- Returns 'gracias' (found in generic es)
```

This feature is particularly useful for:

- Supporting regional language variants
- Sharing common translations while allowing regional differences
- Creating fallback chains for similar languages
- Efficiently managing partial translations

Each locale in the chain is tried in order before falling back to the default locale.
Duplicate locales in the chain are automatically removed.

Using language files
====================

It might be a good idea to store each translation in a different file. This is supported via the 'i18n.loadFile' directive:

``` lua
…
i18n.loadFile('path/to/your/project/i18n/de.lua') -- German translation
i18n.loadFile('path/to/your/project/i18n/en.lua') -- English translation
i18n.loadFile('path/to/your/project/i18n/fr.lua') -- French translation
…
```

The German language file 'de.lua' should read:

``` lua
return {
  de = {
    good_bye = "Auf Wiedersehen!",
    age_msg = "Ihr Alter beträgt %{age}.",
    phone_msg = {
      one = "Sie haben eine neue Nachricht.",
      other = "Sie haben %{count} neue Nachrichten."
    }
  }
}
```

If desired, you can also store all translations in one single file (eg. 'translations.lua'):

``` lua
return {
  de = {
    good_bye = "Auf Wiedersehen!",
    age_msg = "Ihr Alter beträgt %{age}.",
    phone_msg = {
      one = "Sie haben eine neue Nachricht.",
      other = "Sie haben %{count} neue Nachrichten."
    }
  },
  fr = {
    good_bye = "Au revoir !",
    age_msg = "Vous avez %{age} ans.",
    phone_msg = {
      one = "Vous avez une nouveau message.",
      other = "Vous avez %{count} nouveaux messages."
    }
  },
  …
}
```

Specs
=====
This project uses [busted](https://github.com/Olivine-Labs/busted) for its specs. If you want to run the specs, you will have to install it first. Then just execute the following from the root inspect folder:

    busted
