# encoding: utf-8
module Sys::Model::ConditionBuilder
  @_cb_condition = nil
  @_cb_extention = nil
  
  def condition
    @_cb_condition = Condition.new() unless @_cb_condition
    return @_cb_condition
  end
  
  def cb_condition_where
    condition.where
  end
  
  def cb_extention
    @_cb_extention = {} unless @_cb_extention
    return @_cb_extention
  end
  
  def and(*args, &block)
    condition.and(*args, &block)
  end
  
  def or(*args, &block)
    condition.or(*args, &block)
  end
  
  def and_in_ssv(column, value)
    condition.and column, 'REGEXP', "(^| )#{value}( |$)" # Only MySQL
  end
  
  def and_keywords(words, *columns)
    return self unless words =~ /[^ 　]/
    cond = Condition.new
    columns.each do |col|
      cond.or do |c|
        words.to_s.split(/[ 　]+/).uniq.each_with_index do |w, i|
          break if i >= 10
          qw = connection.quote_string(w).gsub(/([_%])/, '\\\\\1')
          c.and col, 'LIKE', "%#{qw}%"
        end
      end
    end
    self.and cond
    self
  end
  
  def join(condition)
    cb_extention[:joins] = [] unless cb_extention[:joins]
    case condition
    when Symbol
      cb_extention[:joins] << condition
    else
      cb_extention[:joins] << condition
    end
    cb_extention[:joins] = cb_extention[:joins].uniq
  end
  
  def order(columns, default = nil)
    if columns.to_s != ''
      cb_extention[:order] = columns
    elsif default.to_s != ''
      cb_extention[:order] = default
    end
  end
  
  def page(page, limit = 30)
    if limit.to_s == '0'
      cb_extention.delete :page
      cb_extention.delete :limit
    else
      page = 1 unless page.to_s =~ /^[1-9][0-9]*$/
      cb_extention[:page]  = page
      cb_extention[:limit] = limit
    end
  end
  
  def find(*args)
    scope   = args.slice!(0)
    options = args.slice!(0) || {}
    options[:conditions] = cb_condition_where   unless options[:conditions]
    options[:joins]      = cb_extention[:joins] unless options[:joins]
    options[:order]      = cb_extention[:order] unless options[:order]
    
    ext = cb_extention
    return self.class.find(scope, options) unless ext[:page]
    
    options[:page]     = ext[:page]
    options[:per_page] = ext[:limit]
    return self.class.paginate(options)
  end
  
  def count(*args)
    options     = {}
    column_name = :all
    
    case args.size
    when 1
      args[0].is_a?(Hash) ? options = args[0] : column_name = args[0]
    when 2
      column_name, options = args
    else
      raise ArgumentError, "Unexpected parameters passed to count(): #{args.inspect}"
    end if args.size > 0

    options[:conditions] = cb_condition_where unless options[:conditions]
    return self.class.count(column_name, options)
  end
end
