# encoding: utf-8
class Calendar::Event < ActiveRecord::Base
  include Sys::Model::Base
  include Cms::Model::Base::Page
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::Creator
  include Cms::Model::Rel::Content
  include Cms::Model::Rel::EmbeddedFile
  include Cms::Model::Auth::Concept

  belongs_to :status,         :foreign_key => :state,             :class_name => 'Sys::Base::Status'

  #embed_file_of :image_file_id
  
  validates_presence_of :state, :event_date, :title
  
  validate :validates_event_date,
    :if => %Q(!event_date.blank? && !event_close_date.blank?)
  
  def validates_event_date
    if event_date >= event_close_date
      errors.add :event_close_date, :greater_than, :count => locale(:event_date)
      return false
    end
  end
  
  def event_date_in(sdate, edate)
    self.and Condition.new do |c|
      c.or Condition.new do |c2|
        c2.and :event_date, "<", edate.to_s
        c2.and :event_close_date, ">=", sdate.to_s
      end
      c.or Condition.new do |c2|
        c2.and :event_close_date, "IS", nil
        c2.and :event_date, ">=", sdate.to_s
        c2.and :event_date, "<", edate.to_s
      end
    end
    self
  end

  def search(params)
    params.each do |n, v|
      next if v.to_s == ''

      case n
      when 's_event_date'
        self.and :event_date, v
      when 's_title'
        self.and_keywords v, :title
      end
    end if params.size != 0

    return self
  end
end