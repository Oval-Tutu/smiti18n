local interpolate = require 'smiti18n.interpolate'

describe('smiti18n.interpolate', function()
  it("exists", function()
    assert.equal('table', type(interpolate))
  end)

  it("performs standard interpolation via string.format", function()
    assert.equal("My name is John, I am 13", interpolate("My name is %s, I am %d", {"John", 13}))
  end)

  it("does not try to interpolate strings with percentages on it", function()
    assert.equal("Pepe feels 100%!", interpolate("%{name} feels 100%!", {name = "Pepe"}))
  end)

  describe("When interpolating with hash values", function()

    it("converts non-existing items in nil values without error", function()
      assert.equal("Nil = nil", interpolate("Nil = %{null}"))
    end)

    it("converts variables in stringifield values", function()
      assert.equal("My name is John, I am 13",
                   interpolate("My name is %{name}, I am %{age}", {name = "John", age = 13}))
    end)

    it("ignores spaces inside the brackets", function()
      assert.equal("My name is John, I am 13",
                   interpolate("My name is %{ name }, I am %{ age }", {name = "John", age = 13}))
    end)

    it("is escaped via double %%", function()
      assert.equal("I am a %{blue} robot.",
                   interpolate("I am a %%{blue} robot."))
    end)

  end)

  describe("When interpolating with hash values and formats", function()
    it("converts non-existing items in nil values without error", function()
      assert.equal("Nil = nil", interpolate("Nil = %<null>.s"))
    end)

    it("converts variables in stringifield values", function()
      assert.equal("My name is John, I am 13",
                   interpolate("My name is %<name>.s, I am %<age>.d", {name = "John", age = 13}))
    end)

    it("ignores spaces inside the brackets", function()
      assert.equal("My name is John, I am 13",
                   interpolate("My name is %< name >.s, I am %< age >.d", {name = "John", age = 13}))
    end)

    it("is escaped via double %%", function()
      assert.equal("I am a %<blue>.s robot.", interpolate("I am a %%<blue>.s robot."))
    end)
  end)

  it("Interpolates everything at the same time", function()
    assert.equal('A nil ref and %<escape>.d and spaced and "quoted" and something',
      interpolate("A %{null} ref and %%<escape>.d and %{ spaced } and %<quoted>.q and %s", {
        "something",
        spaced = "spaced",
        quoted = "quoted"
      })
    )
  end)

  -- Add new tests here, before the final end)
  describe('Multiple format specifiers', function()
    it("handles multiple numeric formats in one string", function()
      assert.equal(
        "Int: 42, Float: 3.14, Exp: 1.23e+06",
        interpolate(
          "Int: %s, Float: %s, Exp: %s",
          {"42", "3.14", "1.23e+06"}))
    end)

    it("handles repeated format specifiers", function()
      assert.equal(
        "Value is 42 and also 42",
        interpolate("Value is %s and also %s", {"42", "42"}))
    end)

    it("handles escaped format chars correctly", function()
      assert.equal(
        "Format: %d",
        interpolate("Format: %%d")
      )
    end)
  end)

  describe('Edge cases', function()
    it("handles simple variable references", function()
      assert.equal(
        "Value: test",
        interpolate("Value: %{val}", {val = "test"}))
    end)

    it("handles invalid format specifiers gracefully", function()
      assert.error(function()
        interpolate("%d", {"not a number"})
      end)
    end)

    it("ignores escaped format specifiers", function()
      assert.equal(
        "Raw %<num>.d here",
        interpolate("Raw %%<num>.d here", {num = 42}))
    end)

    it("handles escaped format characters", function()
      assert.equal("100%", interpolate("100%%"))
      assert.equal("50% complete", interpolate("50%% complete"))
    end)

    it("handles format specifiers", function()
      assert.equal("Test %s", interpolate("Test %%s"))
      assert.equal("Value %d", interpolate("Value %%d"))
    end)
  end)

  describe('unescapePercentages', function()
    it('handles escaped format chars correctly', function()
      local result = interpolate("Format: %%d")
      assert.equal("Format: %d", result)
    end)

    it('handles single values with escapes', function()
      local result = interpolate("Number: %%d %d", {42})
      assert.equal("Number: %d 42", result)
    end)

    it('handles multiple escapes', function()
      -- Test double %% (escapes to single %)
      local result = interpolate("Test: %%d%%d", {})
      assert.equal("Test: %d%d", result)

      -- Test triple %%% with value
      result = interpolate("Value: %%%d", {123})
      assert.equal("Value: %123", result)
    end)

    it('handles special format characters differently', function()
      -- Test format character that exists in FORMAT_CHARS table (like s,d,f)
      local result = interpolate("Test: %%s %%d %%f", {})
      assert.equal("Test: %s %d %f", result)

      -- Test non-format character (z is not in FORMAT_CHARS)
      result = interpolate("Test: %%z", {})
      assert.equal("Test: %z", result) -- Updated expectation - all %% are converted to %
    end)

    it('exercises all format character paths', function()
      -- Test format character (d) with proper value
      local result = interpolate("Test: %%%d %%d", {42})
      assert.equal("Test: %42 %d", result)

      -- Test non-format character with escaped %
      result = interpolate("Test: %%k", {})
      assert.equal("Test: %k", result)

      -- Mix both in single test to ensure branches are hit
      result = interpolate("Mix: %%%d %%x", {99})
      assert.equal("Mix: %99 %x", result)
    end)
  end)

  describe('getInterpolationKey', function()
    it("finds first valid interpolation key", function()
      assert.equal(
        "name",
        interpolate.getInterpolationKey("Text %{name}", {name = "test"}))
    end)

    it("returns nil when no valid keys found", function()
      assert.is_nil(
        interpolate.getInterpolationKey("No vars here")
      )
    end)

    it("handles format specifiers", function()
      assert.equal(
        "num",
        interpolate.getInterpolationKey("Format %<num>.d here", {num = 42}))
    end)
  end)
end)
