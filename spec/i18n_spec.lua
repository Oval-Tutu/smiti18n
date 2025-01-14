require 'spec.fixPackagePath'

local i18n = require 'smiti18n'

describe('i18n', function()

  before_each(function() i18n.reset() end)

  describe('locale files', function()
    before_each(function()
      i18n.reset()
    end)

    -- Helper to get list of locale files
    local function getLocaleFiles()
      local files = {}
      local handle = io.popen('ls locales/*.lua')
      local result = handle:read("*a")
      handle:close()
      for file in result:gmatch("[^\n]+") do
        table.insert(files, file)
      end
      return files
    end

    it('can load all locale files', function()
      local files = getLocaleFiles()
      assert.is_true(#files > 0, "No locale files found in locales/ directory")

      for _, file in ipairs(files) do
        print("Testing " .. file)

        -- Load the file
        local chunk, err = loadfile(file)
        assert.is_nil(err, "Error loading " .. file .. ": " .. tostring(err))

        -- Execute the chunk
        local ok, result = pcall(chunk)
        assert.is_true(ok, "Error executing " .. file)
        assert.is_table(result, file .. " should return a table")

        -- Get language code from filename
        local langCode = file:match("locales/([^/]+)%.lua$"):gsub("%.lua$", "")

        -- Verify basic structure
        assert.is_table(result[langCode], file .. " should have language code table")

        -- Optional _formats check
        if result[langCode]._formats then
          assert.is_table(result[langCode]._formats, file .. " _formats should be a table if present")
        end

        -- Load into i18n
        i18n.load(result)
      end
    end)
  end)

  describe('translate/set', function()
    it('sets a value in the internal store', function()
      i18n.set('en.foo','var')
      assert.equal('var', i18n('foo'))
    end)

    it('splits keys via their dots', function()
      i18n.set('en.message.cool', 'hello!')
      assert.equal('hello!', i18n('message.cool'))
    end)

    it('interpolates variables', function()
      i18n.set('en.message', 'Hello %{name}, your score is %{score}')
      assert.equal('Hello Vegeta, your score is 9001', i18n('message', {name = 'Vegeta', score = 9001}))
    end)

    it('checks that the first two parameters are non-empty strings', function()
      assert.error(function() i18n.set("","") end)
      assert.error(function() i18n.set("",1) end)
      assert.error(function() i18n.set(1,1) end)
      assert.error(function() i18n.set() end)
    end)

    describe('when an entry is missing', function()

      describe('and a locale parameter is given', function()
        it('uses the given locale', function()
          i18n.set('es.msg', 'hola')
          assert.equal('hola', i18n('msg', {locale = 'es'}))
        end)
      end)

      it('looks it up in locale ancestry', function()
        i18n.set('es.msg', 'hola')
        i18n.setLocale('es-MX')
        assert.equal('hola', i18n('msg'))
      end)

      it('uses the fallback locale', function()
        i18n.set('es.msg', 'hola')
        i18n.setLocale('fr')
        assert.is_nil(i18n('msg'))
        i18n.setFallbackLocale('es')
        assert.equal('hola', i18n('msg'))
      end)

      it('uses the fallback locale ancestry', function()
        i18n.set('es.msg', 'hola')
        i18n.setLocale('fr')
        assert.is_nil(i18n('msg'))
        i18n.setFallbackLocale('es-MX')
        assert.equal('hola', i18n('msg'))
      end)

      it('uses the default parameter, if given', function()
        assert.equal('bonjour', i18n('msg', {default='bonjour'}))
      end)

      it('interpolates the default parameter, if given', function()
        assert.equal('bonjour world', i18n('msg', {default='bonjour %{who}', who="world"}))
      end)

      it('throws errors on invalid inputs', function()
        assert.error(function()
          i18n.set('en.test', 123)  -- Number should error
        end)
        assert.error(function()
          i18n.set('en.test', true) -- Boolean should error
        end)
      end)
    end)

    describe("locale fallback", function()
      local TEST_KEY = 'test_fallback.hello'

      before_each(function()
        i18n.setLocale('en') -- Reset to default
        i18n.set('en.' .. TEST_KEY, 'Hello')
        i18n.set('fr.' .. TEST_KEY, 'Bonjour')
      end)

      it("falls back to default locale", function()
        i18n.setLocale("unknown")
        local result = i18n.translate(TEST_KEY)
        assert.equals("Hello", result)
      end)

      it("handles table locales", function()
        i18n.setLocale({"fr", "en"})
        local result = i18n.translate(TEST_KEY)
        assert.equals("Bonjour", result)
      end)

      after_each(function()
        i18n.setLocale('en')
      end)
    end)

    describe('when there is a count-type translation', function()
      describe('and the locale is the default one (english)', function()
        before_each(function()
          i18n.setLocale('en')
          i18n.set('en.message', {
            one   = "Only one message.",
            other = "%{count} messages."
          })
        end)

        it('pluralizes correctly', function()
          assert.equal("Only one message.", i18n('message', {count = 1}))
          assert.equal("2 messages.", i18n('message', {count = 2}))
          assert.equal("0 messages.", i18n('message', {count = 0}))
        end)

        it('defaults to 1', function()
          assert.equal("Only one message.", i18n('message'))
        end)
      end)

      describe('and the locale is french', function()
        before_each(function()
          i18n.setLocale('fr')
          i18n.set('fr.message', {
            one   = "%{count} chose.",
            other = "%{count} choses."
          })
        end)

        it('Ça marche', function()
          assert.equal("1 chose.", i18n('message', {count = 1}))
          -- Note: should actually be '1,5 chose.'
          assert.equal("1.5 chose.", i18n('message', {count = 1.5}))
          assert.equal("2 choses.", i18n('message', {count = 2}))
          assert.equal("0 chose.", i18n('message', {count = 0}))
        end)

        it('defaults to 1', function()
          assert.equal("1 chose.", i18n('message'))
        end)
      end)

    end)
  end)

  describe('load', function()
    it("loads a bunch of stuff", function()
      i18n.load({
        en = {
          hello  = 'Hello!',
          inter  = 'Your weight: %{weight}',
          plural = {
            one = "One thing",
            other = "%{count} things"
          }
        },
        es = {
          hello  = '¡Hola!',
          inter  = 'Su peso: %{weight}',
          plural = {
            one = "Una cosa",
            other = "%{count} cosas"
          }
        }
      })

      assert.equal('Hello!', i18n('hello'))
      assert.equal('Your weight: 5', i18n('inter', {weight = 5}))
      assert.equal('One thing', i18n('plural', {count = 1}))
      assert.equal('2 things', i18n('plural', {count = 2}))
      i18n.setLocale('es')
      assert.equal('¡Hola!', i18n('hello'))
      assert.equal('Su peso: 5', i18n('inter', {weight = 5}))
      assert.equal('Una cosa', i18n('plural', {count = 1}))
      assert.equal('2 cosas', i18n('plural', {count = 2}))
      i18n.setLocale('pl')
      assert.equal('Your weight: 5', i18n('inter', {weight = 5}))
      assert.equal('One thing', i18n('plural', {count = 1}))
      assert.equal('0 things', i18n('plural', {count = 0}))
      assert.equal('2 things', i18n('plural', {count = 2}))
    end)
  end)

  describe('format configuration', function()
    before_each(function()
      i18n.reset()
    end)

    it('allows direct format configuration and retrieval', function()
      -- Test format configuration
      local formats = {
        currency = {
          symbol = "€",
          name = "Euro"
        }
      }
      i18n.configure(formats)

      -- Test config retrieval
      local config = i18n.getConfig()
      assert.equal("€", config.currency.symbol)
      assert.equal("Euro", config.currency.name)
    end)
  end)

  describe('loadFile', function()
    after_each(function()
      _G.love = nil
      i18n.reset()
    end)

    it("loads a bunch of stuff", function()
      i18n.loadFile('spec/en-UK.lua')
      i18n.setLocale('en-UK')
      assert.equal('Hello!', i18n('hello'))
      local balance = i18n('balance', {value = 0})
      assert.equal('Your account balance is 0.', balance)
      assert.same({"one", "two", "three"}, i18n('array'))
    end)

    it('uses LÖVE filesystem when available', function()
      _G.love = {
        filesystem = {
          read = function(path)
            if path == 'test.lua' then
              return [[return { en = { test = "LÖVE File" } }]]
            end
          end
        }
      }

      i18n.loadFile('test.lua')
      assert.equal('LÖVE File', i18n('test'))
    end)

    it('handles LÖVE filesystem errors', function()
      _G.love = {
        filesystem = {
          read = function(path)
            return nil, "File not found error"
          end
        }
      }

      assert.error_matches(function()
        i18n.loadFile('nonexistent.lua')
      end, "Could not load i18n file: File not found error")
    end)

    it('handles LÖVE parse errors', function()
      _G.love = {
        filesystem = {
          read = function(path)
            return "this is not valid lua"
          end
        }
      }

      assert.error_matches(function()
        i18n.loadFile('bad.lua')
      end, "Could not parse i18n file:")
    end)

    it('falls back to standard Lua IO when love has no filesystem', function()
      _G.love = {}
      i18n.loadFile('spec/en-UK.lua')
      i18n.setLocale('en-UK')
      assert.equal('Hello!', i18n('hello'))
    end)

    it('handles filesystem read errors for standard Lua', function()
      local badPath = 'nonexistent_file.lua'
      assert.error_matches(function()
        i18n.loadFile(badPath)
      end, "Could not load i18n file:")
    end)

    it('errors when file returns non-table', function()
      assert.error_matches(function()
        i18n.loadFile('spec/invalid_return.lua')
      end, "i18n file must return a table")
    end)

    it('errors when LÖVE file returns non-table', function()
      _G.love = {
        filesystem = {
          read = function(path)
            return "return 123"
          end
        }
      }

      assert.error_matches(function()
        i18n.loadFile('test.lua')
      end, "i18n file must return a table")
    end)
  end)

  describe('arrays', function()
    it("Load supports arrays of strings", function()
      i18n.set('en.array', {"one", "two", "three"})
      assert.same({"one", "two", "three"},i18n('array'))
    end)

    it("Arrays respect languages", function()
      i18n.set('en.array', {"one", "two", "three"})
      i18n.set('fr.array', {"un", "deux", "trois"})
      i18n.setLocale('fr')
      assert.same({"un", "deux", "trois"},i18n('array'))
    end)

    it("Variables in array elements can be interpolated", function()
      i18n.set('en.suede', {"%{count} for the count", "%{show} for the show", "%{ready} to make ready", "go!"})
      assert.same({
        "one for the count",
        "two for the show",
        "three to make ready",
        "go!"
      },i18n('suede',{count = "one", show = "two", ready = "three"}))
    end)

    it("Interpolation produces different results when called with different values", function()
      i18n.set('en.suede', {"%{count} for the count", "%{show} for the show", "%{ready} to make ready", "go!"})
      assert.same({
        "one for the count",
        "two for the show",
        "three to make ready",
        "go!"
      },i18n('suede',{count = "one", show = "two", ready = "three"}))

      assert.same({
        "a for the count",
        "b for the show",
        "c to make ready",
        "go!"
      },i18n('suede',{count = "a", show = "b", ready = "c"}))
    end)

    it("Variables in array elements can be pluralized", function()
      i18n.set('en.safe', {"Welcome to Apature!", {
        one = "%{count} unfortunate retirement today!",
        other = "%{count} unfortunate retirements today!"}
      })
      assert.same({
        "Welcome to Apature!",
        "1 unfortunate retirement today!",
      },i18n('safe',{count = 1}))
    end)

    it("Variables in array elements can be pluralized independently", function()
      i18n.set('en.safe', {
        "Welcome to Apature!", {
          one = "%{count} unfortunate retirement today!",
          other = "%{count} unfortunate retirements today!"
        }, {
          one = "only %{test} test subject active!",
          other = "%{test} test subjects active"
        }
      })
      assert.same({
        "Welcome to Apature!",
        "10 unfortunate retirements today!",
        "only 1 test subject active!"
      },i18n('safe',{count = 10, test = 1}))
    end)

    it("Without field or value names in string. Pluralisation assumes count as default key", function()
      i18n.set('en.safe', {
        "Welcome to Apature!", {
          one = "It's great!",
          other = "It's mostly safe!"
        }
      })
      assert.same({
        "Welcome to Apature!",
        "It's mostly safe!",
     },i18n('safe',{count = 2}))
    end)

    it("Handles mixed data in pluralization", function()
      i18n.set('en.msg', {
        one = "Count is %{count}, name is %{name}",
        other = "Counts are %{count}, name is %{name}"
      })
      assert.equal(
        "Count is 1, name is test",
        i18n('msg', {count = 1, name = "test"})
      )
    end)

    it("copies data correctly for pluralization", function()
      i18n.set('en.test', {
        one = "Count: %{count}",
        other = "Count: %{count}"
      })
      local data = {count = 1}
      assert.equal("Count: 1", i18n('test', data))
      data.count = 2  -- Modify original data
      assert.equal("Count: 2", i18n('test', data))
    end)
  end)

  describe('set/getFallbackLocale', function()
    it("defaults to en", function()
      assert.equal('en', i18n.getFallbackLocale())
    end)
    it("throws error on empty or erroneous locales", function()
      assert.error(i18n.setFallbackLocale)
      assert.error(function() i18n.setFallbackLocale(1) end)
      assert.error(function() i18n.setFallbackLocale("") end)
    end)
  end)

  describe('set/getLocale', function()
    it("defaults to en", function()
      assert.equal('en', i18n.getLocale())
    end)

    it("modifies translate", function()
      i18n.set('fr.foo','bar')
      i18n.setLocale('fr')
      assert.equal('bar', i18n('foo'))
    end)

    it("does NOT modify set", function()
      i18n.setLocale('fr')
      i18n.set('fr.foo','bar')
      assert.equal('bar', i18n('foo'))
    end)

    it("does NOT modify load", function()
      i18n.setLocale('fr')
      i18n.load({fr = {foo = 'Foo'}})
      assert.equal('Foo', i18n('foo'))
    end)

    it("does NOT modify loadFile", function()
      i18n.loadFile('spec/en-UK.lua')
      i18n.setLocale('en-UK')
      assert.equal('Hello!', i18n('hello'))
    end)

    it("handles table locales", function()
      i18n.setLocale({'fr-CA', 'fr'})
      i18n.set('fr.msg', {one = '%{count} thing', other = '%{count} things'})
      assert.equal('1 thing', i18n('msg', {count = 1}))
    end)

    describe("when a second parameter is passed", function()
      it("throws an error if the second param is not a function", function()
        assert.error(function() i18n.setLocale('wookie', 1) end)
        assert.error(function() i18n.setLocale('wookie', 'foo') end)
        assert.error(function() i18n.setLocale('wookie', {}) end)
      end)
      it("uses the provided function to calculate plurals", function()
        local count = function(n)
          return (n < 10 and "hahahaha") or "other"
        end
        i18n.setLocale('dracula', count)
        i18n.load({dracula = { msg = { hahahaha = "Let's count to %{count}. hahahaha", other = "wha?" }}})

        assert.equal("Let's count to 5. hahahaha", i18n('msg', {count = 5}))
        assert.equal("Let's count to 3. hahahaha", i18n('msg', {count = 3}))
        assert.equal("wha?", i18n('msg', {count = 11}))
      end)
    end)
  end)

  -- New tests to improve coverage
  describe('defaultPluralizeFunction', function()
    it("handles table locales correctly", function()
      i18n.setLocale({'en-US', 'en'})
      i18n.set('en.msg', {
        one = "One item",
        other = "Multiple items"
      })
      assert.equal("One item", i18n('msg', {count = 1}))
      assert.equal("Multiple items", i18n('msg', {count = 2}))
    end)
  end)

  describe('i18n additional tests', function()
    before_each(function() i18n.reset() end)

    describe('error handling', function()
        it('throws an error when setting a non-string or non-table value', function()
            assert.error(function() i18n.set('en.test', 123) end)
            assert.error(function() i18n.set('en.test', true) end)
        end)

        it('throws an error when setting an invalid locale', function()
            assert.error(function() i18n.setLocale(123) end)
            assert.error(function() i18n.setLocale('') end)
        end)

        it('throws an error when setting an invalid fallback locale', function()
            assert.error(function() i18n.setFallbackLocale(123) end)
            assert.error(function() i18n.setFallbackLocale('') end)
        end)

        it('throws an error when setting a non-function custom pluralize function', function()
            assert.error(function() i18n.setLocale('en', 123) end)
            assert.error(function() i18n.setLocale('en', 'not a function') end)
        end)
    end)

    describe('defaultPluralizeFunction', function()
        it('uses the default locale when locale is not provided', function()
            i18n.set('en.msg', {one = "One item", other = "Multiple items"})
            assert.equal("One item", i18n('msg', {count = 1}))
            assert.equal("Multiple items", i18n('msg', {count = 2}))
        end)
    end)
  end)
end)
