# encoding: utf-8
module Faq::Model::Rel::Doc::Category
  extend ActiveSupport::Concern

  included do
    scope :category_is, ->(cate) {
      return all if cate.blank?
      cate = [cate] unless cate.class == Array
      ids  = []

      searcher = lambda do |_cate|
        _cate.each do |_c|
          next if _c.blank?
          next if _c.level_no > 4
          next if ids.index(_c.id)
          ids << _c.id
          searcher.call(_c.public_children)
        end
      end

      searcher.call(cate)
      ids = ids.uniq

      if ids.empty?
        all
      else
        where(
          arel_table[:category_ids].in(ids)
          .or(arel_table[:category_ids].matches("#{ids.join('|')} %"))
          .or(arel_table[:category_ids].matches("% #{ids.join('|')} %"))
          .or(arel_table[:category_ids].matches("% #{ids.join('|')}"))
        )
      end
    }
  end

  def in_category_ids
    val = @in_category_ids
    @in_category_ids = category_ids.to_s.split(' ').uniq unless val
    @in_category_ids
  end

  def in_category_ids=(ids)
    _ids = []
    if ids.class == Array
      ids.each { |val| _ids << val }
      self.category_ids = _ids.join(' ')
    elsif ids.class == Hash || ids.class == HashWithIndifferentAccess \
          || ids.class == ActionController::Parameters
      ids.each { |_key, val| _ids << val }
      self.category_ids = _ids.join(' ')
    else
      self.category_ids = ids
    end
  end

  def category_items
    ids = category_ids.to_s.split(' ').uniq
    return [] if ids.empty?

    Faq::Category.where(id: ids)
  end

end
