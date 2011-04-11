class Line_Calendar < Geeklet
  # register command line arguments with configurableValue
  registerConfiguration :Line_Calendar, :color, :default => "green", :description => "color of current date identifier", :type => :string
  registerConfiguration :Line_Calendar, :hicolor, :default => "no", :description => "use the bright value of color option", :type => :string
  registerConfiguration :Line_Calendar, :vertical, :default => "no", :description => "build the calendar vertically", :type => :string

  # set up some constants for use in throughout the script
  COLOR_STRING = "◆◆" # the string used to denote the current day
  SEPARATOR_STRING_A = "  " # the string used to separate days and dates
  SEPARATOR_STRING_B = "··" # the string used between seperators
  SEPARATOR_STRING_C = "··" # the separator string
  END_COLOR = "\e[0m" # this string ends color output
  HI_COLOR = "\e[1m" # this string denotes bold color
  ABBR_DAYNAMES = {0, 'Su', 1, 'Mo', 2, 'Tu', 3, 'We', 4, 'Th', 5, 'Fr', 6, 'Sa'} # map of abbreviated day names to matching index for date functions
  # hash of the different colors available as ASCII output
  COLORS = {'black', "\e[30m", 'red', "\e[31m", 'green', "\e[32m", 'yellow', "\e[33m", 'blue', "\e[34m", 'magenta', "\e[35m", 'cyan', "\e[36m", 'white', "\e[37m"}

  # prints the name
  def name
    "Line Calendar"
  end
  
  # prints the descriptions
  def description
    "Outputs a monthly calendar in a single line"
  end

  # returns intiger with number of days in the month (28, 29, 30, 31)
  def days_in_month(year, month)
    return (Date.new(year, 12, 31) << (12 - month)).day
  end
  
  # returns what day of the month it is (1-31)
  def day_in_month(year, month, day)
    return Date.new(year, month, day).wday
  end
  
  # returns an array of days in the month (Mo, Tu, We, etc.)
  def build_day_array(year, month)
    day_array = Array.new
    # cycle through number of days in the month and build an array with one entry per day
    for d in (1..self.days_in_month(year, month))
      day_array[d] = Line_Calendar::ABBR_DAYNAMES[self.day_in_month(year, month, d)] # populates array with abbreviated daynames
    end
    # remove the 0 entry and move everything up one
    day_array.shift
    return day_array
  end
  
  # builds the separator line between the days and dates
  def build_separator(year, month)
    separator = Array.new
    # cycle through days in month
    for d in (1..self.days_in_month(year, month))
      # if day in month matches today use colorized date indicator
      if year == Time.now.year && month == Time.now.month && d == Time.now.day then
        # use hicolor flag?
        configurableValue(:Line_Calendar, :hicolor) == "yes" ? separator[d] = HI_COLOR : separator[d] = ""
        # append colorized date string to array
        separator[d] += Line_Calendar::COLORS[configurableValue(:Line_Calendar, :color)] + Line_Calendar::COLOR_STRING + Line_Calendar::END_COLOR
      else
        # append normal separator to the array
        separator[d] = Line_Calendar::SEPARATOR_STRING_B
      end
    end
    # trim 0 key and move everything up one
    separator.shift
    return separator
  end
  
  # build array of dates (1-31)
  def build_date_array(year, month)
    date_array = Array.new
    # cycle through days in month creating one key in the array for each day
    for d in (1..self.days_in_month(year, month))
      date_array[d] = d
    end
    # remove 0 key for 1 to 1 mapping in array
    date_array.shift
    # make sure all dates are two digits
    date_array.each do |d|
      if d < 10 then
        # if date is 1-9 make sure it is 01-09
        date_array[(d -1)] = "0#{d}"
      end
    end
    return date_array
  end

  # build array vertically instead of horizontally
  def build_vertical_array(year, month)
    # pull in arrays of days and dates
    dates = self.build_date_array(Time.now.year, Time.now.month)
    days = self.build_day_array(Time.now.year, Time.now.month)
    
    # zip the two arrays so we have the following single array to work with
    # [['Mo', '01'], ['Tu', '02']]
    vertical = days.zip(dates)
    
    return vertical
  end

  # function autoran by geeklets framework
  def run(params)
    # pull in command line arguments for access (or something)
    super(:Line_Calendar, params)
    year = Time.now.year # current year
    month = Time.now.month # current month
    
    # are we building vertically?
    if configurableValue(:Line_Calendar, :vertical) == "yes" then
      # pull vertical array zip (this can be trimmed up and combined I think)
      varray = self.build_vertical_array(year, month)
      # foreach entry in array
      varray.each do |d|
        # does the day entry match today?
        if year == Time.now.year && month == Time.now.month && d[1].to_i == Time.now.day then
          # colorize accordingly
          configurableValue(:Line_Calendar, :hicolor) == "yes" ? temp_separator = HI_COLOR : temp_separator = ""
          temp_separator += Line_Calendar::COLORS[configurableValue(:Line_Calendar, :color)] + Line_Calendar::COLOR_STRING + Line_Calendar::END_COLOR
        else
          # no color
          temp_separator = Line_Calendar::SEPARATOR_STRING_C
        end
        # print out results one line at a time vertically
        puts d[0].to_s + " " + temp_separator + " " + d[1].to_s
      end
    else
      # print out as normal
      # arrays joined by separator strings
      puts self.build_day_array(year, month) * Line_Calendar::SEPARATOR_STRING_A
      puts self.build_separator(year, month) * Line_Calendar::SEPARATOR_STRING_C
      puts self.build_date_array(year, month) * Line_Calendar::SEPARATOR_STRING_A
    end
  end

end