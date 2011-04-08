class Line_Calendar < Geeklet
  registerConfiguration :Line_Calendar, :color, :default => "green", :description => "color of current date identifier", :type => :string
  registerConfiguration :Line_Calendar, :hicolor, :default => "no", :description => "use the bright value of color option", :type => :string
  registerConfiguration :Line_Calendar, :vertical, :default => "no", :description => "build the calendar vertically", :type => :string

  COLOR_STRING = "◆◆"
  SEPARATOR_STRING_A = "  "
  SEPARATOR_STRING_B = "··"
  SEPARATOR_STRING_C = "··"
  END_COLOR = "\e[0m"
  HI_COLOR = "\e[1m"
  ABBR_DAYNAMES = {0, 'Su', 1, 'Mo', 2, 'Tu', 3, 'We', 4, 'Th', 5, 'Fr', 6, 'Sa'}
  COLORS = {'black', "\e[30m", 'red', "\e[31m", 'green', "\e[32m", 'yellow', "\e[33m", 'blue', "\e[34m", 'magenta', "\e[35m", 'cyan', "\e[36m", 'white', "\e[37m"}

  def name
    "Line Calendar"
  end
  
  def description
    "Outputs a monthly calendar in a single line"
  end

  def days_in_month(year, month)
    return (Date.new(year, 12, 31) << (12 - month)).day
  end
  
  def day_in_month(year, month, day)
    return Date.new(year, month, day).wday
  end
  
  def build_day_array(year, month)
    day_array = Array.new
    for d in (1..self.days_in_month(year, month))
      day_array[d] = Line_Calendar::ABBR_DAYNAMES[self.day_in_month(year, month, d)]
    end
    day_array.shift
    return day_array
  end
  
  def build_separator(year, month)
    separator = Array.new
    for d in (1..self.days_in_month(year, month))
      if year == Time.now.year && month == Time.now.month && d == Time.now.day then
        configurableValue(:Line_Calendar, :hicolor) == "yes" ? separator[d] = HI_COLOR : separator[d] = ""
        separator[d] += Line_Calendar::COLORS[configurableValue(:Line_Calendar, :color)] + Line_Calendar::COLOR_STRING + Line_Calendar::END_COLOR
      else
        separator[d] = Line_Calendar::SEPARATOR_STRING_B
      end
    end
    separator.shift
    return separator
  end
  
  def build_date_array(year, month)
    date_array = Array.new
    for d in (1..self.days_in_month(year, month))
      date_array[d] = d
    end
    date_array.shift
    date_array.each do |d|
      if d < 10 then
        date_array[(d -1)] = "0#{d}"
      end
    end
    return date_array
  end

  def build_vertical_array(year, month)
    dates = self.build_date_array(Time.now.year, Time.now.month)
    days = self.build_day_array(Time.now.year, Time.now.month)
    
    vertical = days.zip(dates)
    
    return vertical
  end

  def run(params)
    super(:Line_Calendar, params)
    year = Time.now.year
    month = Time.now.month
    
    if configurableValue(:Line_Calendar, :vertical) == "yes" then
      varray = self.build_vertical_array(year, month)
      varray.each do |d|
        if year == Time.now.year && month == Time.now.month && d[1].to_i == Time.now.day then
          configurableValue(:Line_Calendar, :hicolor) == "yes" ? temp_separator = HI_COLOR : temp_separator = ""
          temp_separator += Line_Calendar::COLORS[configurableValue(:Line_Calendar, :color)] + Line_Calendar::COLOR_STRING + Line_Calendar::END_COLOR
        else
          temp_separator = Line_Calendar::SEPARATOR_STRING_C
        end
        puts d[0].to_s + " " + temp_separator + " " + d[1].to_s
      end
    else
      puts self.build_day_array(year, month) * Line_Calendar::SEPARATOR_STRING_A
      puts self.build_separator(year, month) * Line_Calendar::SEPARATOR_STRING_C
      puts self.build_date_array(year, month) * Line_Calendar::SEPARATOR_STRING_A
    end
  end

end