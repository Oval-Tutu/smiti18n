return {
  ["en-UK"] = {
    _formats = {
      currency = {
        symbol = "£",
        name = "British Pound",
        short_name = "GBP",
        decimal_symbol = ".",
        thousand_separator = ",",
        fract_digits = 2,
        positive_symbol = "",
        negative_symbol = "-",
        positive_format = "%c %p%q",
        negative_format = "%c %p%q"
      },
      number = {
        decimal_symbol = ".",
        thousand_separator = ",",
        fract_digits = 2,
        positive_symbol = "",
        negative_symbol = "-"
      },
      date_time = {
        long_time = "%g:%i:%s %a",
        short_time = "%g:%i %a",
        long_date = "%l %d %F %Y",
        short_date = "%d/%m/%Y",
        long_date_time = "%l %d %F %Y %g:%i:%s %a",
        short_date_time = "%d/%m/%Y %g:%i %a"
      },
      short_month_names = {
        "jan", "feb", "mar", "apr", "may", "jun", "jul", "aug", "sep",
        "oct", "nov", "dec"
      },
      long_month_names = {
        "january", "february", "march", "april", "may", "jun", "july",
        "august", "september", "october", "november", "december"
      },
      short_day_names = {
        "sun", "mon", "tue", "wed", "thu", "fri", "sat"
      },
      long_day_names = {
        "sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday"
      }
    },
    hello = 'Hello!',
    balance = 'Your account balance is %{value}.',
    array = {"one", "two", "three"}
  }
}
