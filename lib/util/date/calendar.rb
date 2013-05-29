# encoding: utf-8
class Util::Date::Calendar
  attr_accessor :year_uri
  attr_accessor :month_uri
  attr_accessor :day_uri
  cattr_reader  :wday_specs
  
  @@wday_specs = [
    {:class => 'sun', :label => "日"},
    {:class => 'mon', :label => "月"},
    {:class => 'tue', :label => "火"},
    {:class => 'wed', :label => "水"},
    {:class => 'thu', :label => "木"},
    {:class => 'fri', :label => "金"},
    {:class => 'sat', :label => "土"},
  ]
  
  def initialize(year = nil, month = nil)
    @cy = cy = year || Time.now.year
    @cm = cm = month || Time.now.month
    cd = 1
    unless Date::valid_date?(@cy, @cm, cd)
      @errors = "date out of range"
      return false
    end
    
    ed = end_day(@cy, @cm)
    
    sw = Time.local(@cy, @cm, cd, 0, 0, 0).strftime('%w').to_i
    ew = Time.local(@cy, @cm, ed, 0, 0, 0).strftime('%w').to_i
    
    @pm = pm = (cm - 1) == 0 ? 12 : (cm - 1)
    @py = py = (pm == 12) ? cy - 1 : cy
    pe = end_day(py, pm)
    
    @nm = nm = (cm + 1) == 13 ? 1 : (cm + 1)
    @ny = ny = (nm == 1) ? cy + 1 : cy
    
    @wdays = []
    @days  = []
    
    7.times do |i|
      wday = @@wday_specs[i].clone
      wday[:class] = 'wday ' + wday[:class]
      @wdays << wday
    end
    
    sw.times do |i|
      d = pe - (sw - i) + 1
      day = {:year => py, :month => pm, :day => d, :class => 'prevMonth day'}
      @days << day
    end
    ed.times do |i|
      day = {:year => cy, :month => cm, :day => (i + 1), :class => 'day'}
      @days << day
    end
    (6 - ew).times do |i|
      day = {:year => ny, :month => nm, :day => (i + 1), :class => 'nextMonth day'}
      @days << day
    end
    
    w = 0
    @days.each do |day|
      day[:date] = sprintf('%04d-%02d-%02d', day[:year], day[:month], day[:day])
      
      day[:wday] = w
      day[:wday_label] = @@wday_specs[w][:label]
      
      day[:holiday] = holiday?(day[:year], day[:month], day[:day], w) || nil
      hclass = day[:holiday] ? ' holiday' : ''
      day[:class] += ' ' + @@wday_specs[w][:class] + hclass
      
      w = (w == 6) ? 0 : w + 1
    end
  end
  
  def errors
    @errors
  end
  
  def end_day(year, month)
    day = [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31][month]
    day += 1 if Date.new(year).leap? && month.to_i == 2
    day
  end
  
  def holiday?(year, month, day, wday = nil)
    Util::Date::Holiday.holiday?(year, month, day, wday)
  end
  
  def year
    @cy
  end
  
  def prev_year
    @cy - 1
  end
  
  def next_year
    @cy + 1
  end
  
  def month
    @cm
  end
  
  def month_name
    Time.local(2000, month, 1, 0, 0, 0).strftime('%B')
  end
  
  def prev_month
    @pm
  end
  
  def next_month
    @nm
  end
  
  def prev_month_date
    Date.new(@py, @pm, 1)
  end
  
  def next_month_date
    Date.new(@ny, @nm, 1)
  end
  
  def days
    @days
  end
  
  def prev_year_uri
    @year_uri.gsub(':year', @cy - 1).gsub(':month', sprintf('%02d', @cm))
  end
  
  def next_year_uri
    @year_uri.gsub(':year', @cy + 1).gsub(':month', sprintf('%02d', @cm))
  end
  
  def current_month_uri
    @month_uri.gsub(':year', @cy.to_s).gsub(':month', sprintf('%02d', @cm))
  end
  
  def prev_month_uri
    return false if @_prev_month_uri == false
    @month_uri.gsub(':year', @py.to_s).gsub(':month', sprintf('%02d', @pm))
  end
  
  def prev_month_uri=(uri)
    @_prev_month_uri = uri
  end
  
  def next_month_uri
    return false if @_next_month_uri == false
    @month_uri.gsub(':year', @ny.to_s).gsub(':month', sprintf('%02d', @nm))
  end
  
  def next_month_uri=(uri)
    @_next_month_uri = uri
  end
  
  def day_uri(day)
    @day_uri.gsub(':year', day[:year].to_s).gsub(':month', sprintf('%02d', day[:month])).gsub(':day', sprintf('%02d', day[:day]))
  end
  
  def day_link=(dates)
    @days.each do |day|
      next unless Date::valid_date?(day[:year], day[:month], day[:day])
      d = Date::new(day[:year], day[:month], day[:day])
      if dates.index(d)
        day[:link] = true
      else
        day[:link] = false
      end
    end
  end
  
  def to_html
    html = '<div class="calendar">' + "\n"
    
    html += '<div class="wdays">' + "\n"
    @wdays.each do |w|
      html += '<span class="' + w[:class] + '">' + w[:label].to_s + '</span>' + "\n"
    end
    html += '</div>' + "\n"
    
    html += '<div class="days">' + "\n"
    @days.each do |d|
      html += '<div class="week">' + "\n" if d[:wday] == 0
      if @day_uri && d[:link] != false
        html += '<a class="' + d[:class] + '" href="' + day_uri(d) + '">' + d[:day].to_s + '</a>' + "\n"
      else
        html += '<span class="' + d[:class] + '">' + d[:day].to_s + '</span>' + "\n"
      end
      html += '</div>' + "\n" if d[:wday] == 6
    end
    html += '</div>' + "\n"
    
    html += '<!-- end .calendar --></div>'
    html.html_safe
  end
end
