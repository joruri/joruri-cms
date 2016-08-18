# encoding: utf-8
class Newsletter::Member < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Base::Config
  include Cms::Model::Rel::Content
  include Cms::Model::Auth::Concept
  include Newsletter::Model::Base::Letter

  include StateText

  validates :state, :email, :letter_type, presence: true

  scope :search, ->(params) {
    rel = all

    params.each do |n, v|
      next if v.to_s == ''

      case n
      when 's_id'
        rel = rel.where(id: v)
      when 's_email'
        rel = rel.where(arel_table[:email].matches("%#{v}%"))
      when 's_letter_type'
        rel = rel.where(letter_type: v)
      when 's_state'
        rel = rel.where(state: v)
      end
    end if params.size != 0

    rel
  }

  def mobile?
    letter_type.to_s =~ /mobile/
  end
end
