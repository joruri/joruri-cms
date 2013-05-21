require 'test/unit'
require 'date'
require File.dirname(__FILE__) + '/../lib/condition_builder'

class ConditionBuilderTest < Test::Unit::TestCase
  def test_construction
    cond = Condition.new do |c|
      c.add "one", "like", "two"
    end
    assert_equal "one", cond.args.first.first

    cond = Condition.new do |c|
      c.add "one", ["two", "three"]
    end
    assert_equal "one IN (?)", cond.where.first

    cond = Condition.new do |c|
      c.add "one", "in", ["two", "three"]
    end
    assert_equal "one IN (?)", cond.where.first
  end
  
  # NOTE: For ruby one-liners, you MUST use curly braces for Condition.block, not do / end!
  def test_sub_conditions
    assert_equal ["one = ? AND two = ? AND (three = ? OR four = ?)", 1, 2, 3, 4],
      Condition.block { |c|
        c.and "one", 1
        c.and "two", 2
        c.and { |d|
          d.or "three", 3
          d.or "four", 4
        }
      }

    assert_equal ["one = ? OR two = ? OR (three = ? AND four = ?)", 1, 2, 3, 4],
      Condition.block { |c|
        c.or "one", 1
        c.or "two", 2
        c.or { |d|
          d.and "three", 3
          d.and "four", 4
        }
      }
    
    @user_id = 10
    @dont_override_user_id = false
    assert_equal ["user_id = ? AND (admin = ? OR joined_at < ?)", 10, true, Date.new(2007, 1, 1)], create_overridable_condition

    @dont_override_user_id = true
    assert_equal ["user_id = ?", 10], create_overridable_condition
  end
  
  protected
  
  def create_overridable_condition
    Condition.block { |c|
      c.and "user_id", @user_id
      c.and { |d|
        d.or "admin", true
        d.or "joined_at", "<", Date.new(2007, 1, 1)
      } unless @dont_override_user_id
    }
  end
end