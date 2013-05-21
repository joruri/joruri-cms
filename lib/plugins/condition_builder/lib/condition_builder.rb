# Condition Builder for ActiveRecord
#
# (c) 2005-2006 Ezra Zygmuntovic, Jens-Christian Fischer and Duane Johnson
# distributed under the same license as Ruby On Rails
#
# Version 1.1
#
# Jan 4, 2007: Added "AND" and "OR" using 'and' and 'or'.  Also added ability to use sub-conditions
#   e.g.
#   Condition.block { |c|
#     c.and "user_id", user_id
#     c.and { |d|
#       d.or "admin", 1
#       d.or "joined_at", "<", 10.days.ago
#     } unless @dont_override_user_id
#   }
#

class Condition
  attr_reader :args

  def self.block(&block)
    new(&block).where
  end
  
  def initialize
    @args = []
    yield self if block_given?
  end

  def and(*args, &block)
    @logic = " AND "
    if block_given?
      block(&block)
    else
      @args << args
    end
  end
  alias :add :and
  
  def or(*args, &block)
    @logic = " OR "
    if block_given?
      block(&block)
    else
      @args << args
    end
  end
  
  def block(&block)
    @args << self.class.new(&block)
  end

  def where(conditions = @args)
    return nil if conditions.empty?
    # Build the condition string with ?s using the 'left' array, and
    # build the value string using the 'right' array:
    left, right = [], []
    conditions.each do |column, *values|
      values = [values] unless values.is_a? Array
      
      if (sub_condition = column).is_a? Condition
        # Integrate the sub-condition
        sub_sql, *sub_values = sub_condition.where
        left << "(" + sub_sql + ")"
        right += sub_values
        next
      elsif column.to_s.downcase == "sql"
        # Treat the first 'value' as pure SQL
        left << values.shift
        next
      end
      
      case values.size
      when 0
        raise "No value specified for Condition"
      when 1
        if values.last.is_a?(Array)
          left << "#{column} IN (?)"
        else
          left << "#{column} = ?"
        end
        right << values.last
      when 2
        operator = values.shift
        if values.last.is_a?(Array)
          left << "#{column} IN (?)"
        else
          left << "#{column} #{operator} ?"
        end
        right << values.last
      else
        operator = values.first
        if operator.upcase == "BETWEEN"
          left << "#{column} #{operator} ? AND ?"
          right << values[-2] << values[-1]
        else
          raise "Unknown operator for multiple values in Condition: #{operator}"
        end
      end
    end
    return [left.join(@logic)].concat(right)
  end
end
