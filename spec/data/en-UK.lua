return {
  ["en-UK"] = {
    _formats = {
      number = {
        positive_symbol = "",
        negative_symbol = "-",
        decimal_symbol = ".",
        thousand_separator = ",",
        fract_digits = "2",
      },
      currency = {
        short_name = "GBP",
        decimal_symbol = ".",
        thousand_separator = ",",
        fract_digits = "2",
        positive_symbol = "",
        negative_symbol = "-",
        positive_format = "%c %p%q",
        negative_format = "%c %p%q",
        symbol = "£",
        name = "British Pound",
      },
      short_day_names = {
        "Sun",
        "Mon",
        "Tue",
        "Wed",
        "Thu",
        "Fri",
        "Sat"
      },
      date_time = {
        short_date_time = "%d/%m/%Y %g:%i %a",
        short_time = "%g:%i %a",
        short_date = "%d/%m/%Y",
        long_date_time = "%l %d %F %Y %g:%i:%s %a",
        long_date = "%l %d %F %Y",
        long_time = "%g:%i:%s %a",
      },
      long_day_names = {
        "Sunday",
        "Monday",
        "Tuesday",
        "Wednesday",
        "Thursday",
        "Friday",
        "Saturday"
      },
      short_month_names = {
        "Jan",
        "Feb",
        "Mar",
        "Apr",
        "May",
        "Jun",
        "Jul",
        "Aug",
        "Sep",
        "Oct",
        "Nov",
        "Dec"
      },
      long_month_names = {
        "January",
        "February",
        "March",
        "April",
        "May",
        "Jun",
        "July",
        "August",
        "September",
        "October",
        "November",
        "December"
      },
    },
    ["hello"] = 'Hello!',
    ["balance"] = 'Your account balance is %{value}.',
    ["array"] = {"one", "two", "three"},
  },
}