# encoding: utf-8
class Newsletter::Log < ActiveRecord::Base
  include Sys::Model::Base

  scope :search, ->(params) {
    rel = all

    params.each do |n, v|
      next if v.to_s == ''

      case n
      when 's_id'
        rel = rel.where(id: v)
      when 's_email'
        rel = rel.where(arel_table[:email].matches("%#{v}%"))
      end
    end if params.size != 0

    rel
  }
end
