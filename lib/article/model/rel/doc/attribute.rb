# encoding: utf-8
module Article::Model::Rel::Doc::Attribute
  extend ActiveSupport::Concern

  included do
    scope :attribute_is, ->(attr) {
      return all if attr.blank?
      attr = [attr] unless attr.class == Array
      ids = []

      attr.each do |_c|
        ids << _c.id
      end

      ids = ids.uniq

      where("`#{table_name}`.`attribute_ids` REGEXP ?", "(^| )(#{ids.join('|')})( |$)")

    }
  end

  def in_attribute_ids
    val = @in_attribute_ids
    @in_attribute_ids = attribute_ids.to_s.split(' ').uniq unless val
    @in_attribute_ids
  end

  def in_attribute_ids=(ids)
    _ids = []
    if ids.class == Array
      ids.each { |val| _ids << val }
      self.attribute_ids = _ids.join(' ')
    elsif ids.class == Hash || ids.class == HashWithIndifferentAccess \
          || ids.class == ActionController::Parameters
      ids.each { |_key, val| _ids << val }
      self.attribute_ids = _ids.join(' ')
    else
      self.attribute_ids = ids
    end
  end

  def attribute_items(options = {})
    ids = attribute_ids.to_s.split(' ').uniq
    return [] if ids.empty?

    items = Article::Attribute.where(id: ids)
    items = items.where(state: options[:state]) if options[:state]
    items
  end
end
