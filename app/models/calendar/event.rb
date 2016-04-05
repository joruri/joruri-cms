# encoding: utf-8
class Calendar::Event < ActiveRecord::Base
  include Sys::Model::Base
  include Cms::Model::Base::Page
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::Creator
  include Cms::Model::Rel::Content
  include Cms::Model::Rel::EmbeddedFile
  include Cms::Model::Auth::Concept

  include StateText

  validates :state, :event_date, :title, presence: true

  validate :validates_event_date,
           if: %(!event_date.blank? && !event_close_date.blank?)

   scope :event_date_in, ->(sdate, edate) {
     where(
       arel_table[:event_date].lt(edate.to_s)
       .and(arel_table[:event_close_date].gteq(sdate.to_s))
       .or(arel_table[:event_close_date].eq(nil)
           .and(arel_table[:event_date].gteq(sdate.to_s))
           .and(arel_table[:event_date].lt(edate.to_s)))
     )
   }

   scope :search, -> (params){
     rel = all
     docs = arel_table

     params.each do |n, v|
       next if v.to_s == ''

       case n
       when 's_title'
         rel = rel.where(docs[:title].matches("%#{v}%"))
       when 's_event_date'
         rel = rel.where(docs[:event_date].eq(v))
       end
     end if params.size != 0

     return rel
   }

  def validates_event_date
    if event_date >= event_close_date
      errors.add :event_close_date, :greater_than, count: locale(:event_date)
      return false
    end
  end
end
