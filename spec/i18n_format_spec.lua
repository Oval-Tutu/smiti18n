-- spec/i18n_format_spec.lua
require 'spec.fixPackagePath'

local format = require 'smiti18n.format'
local i18n = require 'smiti18n'

describe("smiti18n format", function()
  local test_date
  local fr_config

  setup(function()
    -- Test date setup
    test_date = {
      year = 1984,
      month = 2,
      day = 17,
      hour = 10,
      min = 42,
      sec = 3,
      wday = 6
    }

    -- Set up French format config
    fr_config = {
      currency = {
        symbol = "€",
        name = "Euro",
        short_name = "EUR",
        decimal_symbol = ",",
        thousand_separator = " ",
        fract_digits = 2,
        positive_symbol = "",
        negative_symbol = "-",
        positive_format = "%p%q %c",
        negative_format = "%p%q %c"
      },
      number = {
        decimal_symbol = ",",
        thousand_separator = " ",
        fract_digits = 2,
        positive_symbol = "",
        negative_symbol = "-"
      },
      date_time = {
        long_time = "%H:%i:%s",
        short_time = "%H:%i",
        long_date = "%l %d %F %Y",
        short_date = "%d/%m/%Y",
        long_date_time = "%l %d %F %Y %H:%i:%s",
        short_date_time = "%d/%m/%Y %H:%i",
        busted_test = "%l %d"  -- Keep test-specific format
      },
      short_month_names = {
        "janv", "févr", "mars", "avr", "mai", "juin",
        "juil", "août", "sept", "oct", "nov", "déc"
      },
      long_month_names = {
        "janvier", "février", "mars", "avril", "mai", "juin",
        "juillet", "août", "septembre", "octobre", "novembre", "décembre"
      },
      short_day_names = {
        "dim", "lun", "mar", "mer", "jeu", "ven", "sam"
      },
      long_day_names = {
        "dimanche", "lundi", "mardi", "mercredi", "jeudi", "vendredi", "samedi"
      }
    }

    i18n.reset()
    i18n.load({
      fr = {
        welcome = "Bienvenue",
        formats = "formats",
        _formats = fr_config
      }
    })
    i18n.setLocale('fr')
  end)

  describe("Date formatting", function()
    it("uses predefined date/time formats", function()
      assert.same(
        "vendredi 17 février 1984 10:42:03",
        format.dateTime("long_date_time", test_date, fr_config.date_time)
      )
    end)

    it("uses custom format from configuration", function()
      assert.same(
        "vendredi 17",
        format.dateTime("busted_test", test_date, fr_config.date_time)
      )
    end)
  end)

  describe('date name arrays', function()
    before_each(function()
      format.configure(nil) -- Reset to defaults
    end)

    describe('month names', function()
      it('uses default long month names', function()
        local result = format.dateTime("%F", {month = 1, year = 2024})
        assert.equal("January", result)

        result = format.dateTime("%F", {month = 12, year = 2024})
        assert.equal("December", result)
      end)

      it('accepts custom long month names', function()
        format.configure({
          long_month_names = {
            "enero", "febrero", "marzo", "abril", "mayo", "junio",
            "julio", "agosto", "septiembre", "octubre", "noviembre", "diciembre"
          }
        })

        local result = format.dateTime("%F", {month = 1, year = 2024})
        assert.equal("enero", result)
      end)

      it('handles invalid month indexes', function()
        local result = format.dateTime("%F", {month = 13, year = 2024})
        assert.equal("", result) -- Out of bounds should return empty string

        result = format.dateTime("%F", {month = 0, year = 2024})
        assert.equal("", result)
      end)

      it('falls back to English month names when not configured', function()
        format.configure({}) -- Empty config
        local result = format.dateTime("%F", {month = 1})
        assert.equal("January", result)
      end)

      it('falls back to English month names when cleared', function()
        format.configure({long_month_names = nil}) -- Explicit nil
        local result = format.dateTime("%F", {month = 1})
        assert.equal("January", result)
      end)
    end)

    describe('day names', function()
      it('uses default long day names', function()
        local result = format.dateTime("%l", {wday = 1, year = 2024})
        assert.equal("Sunday", result)

        result = format.dateTime("%l", {wday = 7, year = 2024})
        assert.equal("Saturday", result)
      end)

      it('accepts custom long day names', function()
        format.configure({
          long_day_names = {
            "domingo", "lunes", "martes", "miércoles", "jueves", "viernes", "sábado"
          }
        })

        local result = format.dateTime("%l", {wday = 1, year = 2024})
        assert.equal("domingo", result)
      end)
      it('handles invalid day indexes', function()
        local result = format.dateTime("%l", {wday = 8, year = 2024})
        assert.equal("", result) -- Out of bounds should return empty string

        result = format.dateTime("%l", {wday = 0, year = 2024})
        assert.equal("", result)
      end)

      it('falls back to English day names when not configured', function()
        format.configure({}) -- Empty config
        local result = format.dateTime("%l", {wday = 1})
        assert.equal("Sunday", result)
      end)
    end)

    describe('short day names', function()
      it('uses default short day names', function()
        local result = format.dateTime("%a", {wday = 1})
        assert.equal("Sun", result)

        result = format.dateTime("%a", {wday = 7})
        assert.equal("Sat", result)
      end)

      it('accepts custom short day names', function()
        format.configure({
          short_day_names = {
            "dom", "lun", "mar", "mié", "jue", "vie", "sáb"
          }
        })
        local result = format.dateTime("%a", {wday = 1})
        assert.equal("dom", result)
      end)

      it('handles invalid day indexes', function()
        local result = format.dateTime("%a", {wday = 8})
        assert.equal("", result)

        result = format.dateTime("%a", {wday = 0})
        assert.equal("", result)
      end)

      it('falls back to English short day names when not configured', function()
        format.configure({}) -- Empty config
        local result = format.dateTime("%a", {wday = 1})
        assert.equal("Sun", result)
      end)
    end)

    describe('configuration inheritance', function()
      it('preserves unmodified arrays when partially configuring', function()
        local original = format.dateTime("%F", {month = 1})
        format.configure({
          currency = { symbol = "TEST" } -- Configure unrelated section
        })
        local after = format.dateTime("%F", {month = 1})
        assert.equal(original, after) -- Month names should be unchanged
      end)

      it('allows mixed default and custom configurations', function()
        format.configure({
          long_month_names = {
            "enero", "febrero", "marzo", "abril", "mayo", "junio",
            "julio", "agosto", "septiembre", "octubre", "noviembre", "diciembre"
          }
          -- No day_names configured - should use defaults
        })

        local month = format.dateTime("%F", {month = 1, wday = 1})
        local day = format.dateTime("%l", {month = 1, wday = 1})

        assert.equal("enero", month)
        assert.equal("Sunday", day)
      end)
    end)
  end)

  describe('short month names', function()
    it('uses default short month names', function()
      local result = format.dateTime("%b", {month = 1})
      assert.equal("Jan", result)

      result = format.dateTime("%b", {month = 12})
      assert.equal("Dec", result)
    end)

    it('accepts custom short month names', function()
      format.configure({
        short_month_names = {
          "ene", "feb", "mar", "abr", "may", "jun",
          "jul", "ago", "sep", "oct", "nov", "dic"
        }
      })
      local result = format.dateTime("%b", {month = 1})
      assert.equal("ene", result)
    end)

    it('handles invalid month indexes', function()
      local result = format.dateTime("%b", {month = 13})
      assert.equal("", result)

      result = format.dateTime("%b", {month = 0})
      assert.equal("", result)
    end)

    it('falls back to English short month names when not configured', function()
      format.configure({}) -- Empty config
      local result = format.dateTime("%b", {month = 1})
      assert.equal("Jan", result)
    end)
  end)

  describe("currency name fallbacks", function()
    before_each(function()
      format.configure(nil) -- Reset to defaults
    end)

    it("falls back to ISO standard for currency name", function()
      -- Test default/ISO fallback
      local config = format.get_config()
      assert.equal("Currency", config.currency.name)

      -- Test custom name
      format.configure({
        currency = {
          name = "Euro"
        }
      })
      config = format.get_config()
      assert.equal("Euro", config.currency.name)
    end)

    it("falls back to ISO standard for currency short_name", function()
      -- Test default/ISO fallback
      local config = format.get_config()
      assert.equal("XXX", config.currency.short_name)

      -- Test custom short name
      format.configure({
        currency = {
          short_name = "EUR"
        }
      })
      config = format.get_config()
      assert.equal("EUR", config.currency.short_name)
    end)

    it("preserves ISO defaults when partially configuring currency", function()
      format.configure({
        currency = {
          symbol = "€"
          -- name and short_name not configured
        }
      })

      local config = format.get_config()
      assert.equal("Currency", config.currency.name)
      assert.equal("XXX", config.currency.short_name)
      assert.equal("€", config.currency.symbol)
    end)
  end)

  describe("Number formatting", function()
    describe("Simple numbers", function()
      it("formats numbers < 1000", function()
        assert.same("123,40", format.number(123.4, fr_config.number))
      end)

      it("formats numbers > 1000", function()
        assert.same("12 345,60", format.number(12345.6, fr_config.number))
      end)

      it("formats negative numbers", function()
        assert.same("-1 234,50", format.number(-1234.5, fr_config.number))
      end)
    end)

    describe("Price formatting", function()
      before_each(function()
        -- Reset to default ISO format before each test
        i18n.reset()
        format.configure(nil)
      end)
      it("includes currency symbol", function()
        assert.same("XXX 5.00", format.price(5))
      end)

      it("formats negative prices correctly", function()
        assert.same("XXX -23.40", format.price(-23.4))
      end)

      it("loads format configs separately from translations", function()
        -- Reset to default ISO format before test
        i18n.reset()
        format.configure(nil)

        -- Load translations without format config
        i18n.load({
          fr = {
            formats = "formats"  -- Just a string translation
          }
        })

        -- First verify translation works
        i18n.setLocale('fr')
        assert.equal("formats", i18n('formats'))  -- Use assert.equal instead

        -- Then verify price formatting uses ISO defaults
        assert.equal("XXX 5.00", i18n.formatPrice(5))
      end)

      it("falls back to default locale formats", function()
        i18n.setLocale('en')
        assert.same("XXX 5.00", i18n.formatPrice(5))
      end)
    end)
  end)

  describe("Format config loading", function()
    setup(function()
      i18n.reset()
      i18n.load({
        fr = {
          welcome = "Bienvenue",
          formats = "formats",
          _formats = fr_config
        }
      })
      i18n.setLocale('fr')
    end)

    it("preserves format configs across locale changes", function()
      i18n.setLocale('fr')
      assert.same("5,00 €", i18n.formatPrice(5))
      i18n.setLocale('en')
      i18n.setLocale('fr')
      assert.same("5,00 €", i18n.formatPrice(5))
    end)
  end)

  describe("format fallback behavior", function()
    setup(function()
      i18n.reset()
      -- Setup locales with different format configurations
      i18n.load({
        ["fr"] = {
          _formats = {
            currency = {
              symbol = "€",
              decimal_symbol = ",",
              positive_format = "%p%q %c"
            }
          }
        },
        ["fr-CA"] = {
          _formats = {
            currency = {
              symbol = "$"  -- Only override symbol
            }
          }
        },
        ["en"] = {
          _formats = {
            currency = {
              symbol = "£",
              decimal_symbol = ".",
              positive_format = "%c%p%q"
            }
          }
        }
      })
    end)

    it("uses exact format config without inheritance", function()
      i18n.setLocale("fr-CA")
      -- Should use ISO defaults except for symbol
      assert.same("$ 5.00", i18n.formatPrice(5))
    end)

    it("falls back entirely to ISO when format undefined", function()
      i18n.setLocale("de")  -- No format config
      assert.same("XXX 5.00", i18n.formatPrice(5))
    end)

    it("does not inherit between related locales", function()
      i18n.setLocale("fr-CA")
      assert.same("$ 5.00", i18n.formatPrice(5))

      i18n.setLocale("fr")
      assert.same("5,00 €", i18n.formatPrice(5))
    end)

    it("uses ISO defaults for undefined format properties", function()
      local partial_config = {
        _formats = {
          currency = {
            symbol = "¥"
            -- Missing other properties
          }
        }
      }
      i18n.load({ ja = partial_config })
      i18n.setLocale("ja")
      -- Should use ISO defaults with custom symbol
      assert.same("¥ 5.00", i18n.formatPrice(5))
    end)
  end)

  -- spec/i18n_format_spec.lua
  describe("ISO defaults", function()
    setup(function()
      i18n.reset()
      i18n.setLocale('xx')  -- Unknown locale
    end)

    it("uses ISO number format", function()
      -- ISO standard: space as thousand separator, point as decimal
      assert.same("1 234.00", format.number(1234))
    end)

    it("uses ISO currency format", function()
      -- ISO standard: symbol first, space separator, point decimal
      assert.same("XXX 1 234.00", i18n.formatPrice(1234))
    end)

    it("uses ISO date format", function()
      local iso_date = {
        year = 2024,
        month = 3,
        day = 25,
        hour = 15,
        min = 45,
        sec = 30,
        wday = 2
      }
      -- Default format changed to match new structure
      assert.same("2024-03-25T15:45:30", format.dateTime(nil, iso_date))
    end)
  end)

  describe("format pattern mutation tests", function()
    it("detects pattern order changes", function()
      local test_patterns = {
        {pattern = "%c %p%q", expect = "XXX 5.00"},
        {pattern = "%p%q %c", expect = "5.00 XXX"},
        {pattern = "%q%c %p", expect = "5.00XXX "},
        {pattern = "%c%p %q", expect = "XXX 5.00"}
      }

      for _, test in ipairs(test_patterns) do
        local test_config = {
          currency = {
            positive_format = test.pattern
          }
        }
        format.configure(test_config)
        assert.same(test.expect, format.price(5))
      end
    end)
  end)

  describe("format config isolation", function()
    it("keeps separate configs for number/currency/date", function()
      local mixed_config = {
        currency = {
          decimal_symbol = ",",
          positive_format = "%p%q %c"
        },
        number = {
          decimal_symbol = "."
        },
        date_time = {
          short_time = "TIME:%H:%M"
        }
      }
      format.configure(mixed_config)

      -- Should use different formats
      assert.same("5,00 XXX", format.price(5))
      assert.same("5.00", format.number(5))
      assert.same("TIME:10:30", format.dateTime("short_time", {hour=10, min=30}))
    end)
  end)

  describe("deep config changes", function()
    local function getConfig()
      return format.get_config()
    end

    it("maintains config independence", function()
      local original = getConfig()

      -- Modify config
      format.configure({
        currency = { symbol = "TEST" }
      })

      local modified = getConfig()

      -- Original should not affect modified
      assert.not_same(original.currency.symbol, modified.currency.symbol)

      -- Other parts should remain unchanged
      assert.same(original.number, modified.number)
    end)
  end)

  describe("edge cases", function()
    it("handles extreme numbers", function()
      -- Test very large numbers
      assert.same("1 000 000.00", format.number(1000000))

      -- Test very small decimals
      assert.same("0.01", format.number(0.009))

      -- Test zero
      assert.same("0.00", format.number(0))

      -- Test near-integer
      assert.same("1.00", format.number(0.999999))
    end)
  end)

  describe("pattern validation", function()
    it("requires all pattern components", function()
      local invalid_patterns = {
        "%c%p",     -- Missing amount
        "%q",       -- Missing currency
        "static",   -- No substitutions
        "",         -- Empty
      }

      for _, pattern in ipairs(invalid_patterns) do
        local test_config = {
          currency = {
            positive_format = pattern
          }
        }
        format.configure(test_config)
        local result = format.price(5)
        assert.truthy(result:match("5"))      -- Must show amount
        assert.truthy(result:match("XXX"))    -- Must show currency
      end
    end)
  end)

  describe("format functions", function()
    it("handles formatNumber with table locale", function()
      i18n.reset()
      i18n.setLocale({"fr-FR", "fr"})
      i18n.load({
        ["fr"] = {
          _formats = {
            number = {
              decimal_symbol = ",",
              fract_digits = 1  -- Explicitly set precision
            }
          }
        }
      })
      assert.equal("1,5", i18n.formatNumber(1.5))
    end)

    it("handles formatNumber fallback to ISO", function()
      i18n.setLocale("unknown")
      assert.equal("1.50", i18n.formatNumber(1.5))  -- ISO uses point and 2 decimals
    end)

    it("handles formatDate with table locale", function()
      i18n.reset()
      i18n.setLocale({"fr-FR", "fr"})
      i18n.load({
        ["fr"] = {
          _formats = {
            date_time = {
              short_date = "%d/%m/%Y"
            }
          }
        }
      })
      local date = {
        year = 2024,
        month = 3,
        day = 25
      }
      assert.equal("25/03/2024", i18n.formatDate("short_date", date))
    end)

    it("respects number format precision", function()
      i18n.reset()
      i18n.load({
        ["fr"] = {
          _formats = {
            number = {
              decimal_symbol = ",",
              fract_digits = 0
            }
          }
        }
      })
      i18n.setLocale("fr")
      assert.equal("42", i18n.formatNumber(42.42))
    end)
  end)
end)
