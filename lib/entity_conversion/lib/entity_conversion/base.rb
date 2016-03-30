# encoding: utf-8
class EntityConversion::Lib::EntityConversion::Base
  def group_id_fields
    # { :class => [ :field, :field ] }
    false
  end

  def text_fields
    # { :class => [ :field, :field ] }
    # { :class => true } # all string
    false
  end

  def group_changed(_new_group, _old_group)
    false
  end

  def group_end(_old_group)
    false
  end
end
