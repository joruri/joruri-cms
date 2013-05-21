# encoding: utf-8
class Cms::DataText < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Base::Page
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::Creator
  include Cms::Model::Rel::Site
  include Cms::Model::Rel::Concept
  include Cms::Model::Auth::Concept
  
  belongs_to :status,  :foreign_key => :state,      :class_name => 'Sys::Base::Status'
  belongs_to :concept, :foreign_key => :concept_id, :class_name => 'Cms::Concept'
  
#  attr_accessible :concept_id, :state
  
  validates_presence_of :concept_id, :state, :name, :title, :body
  validates_uniqueness_of :name, :scope => :concept_id
  validates_format_of :name, :with => /^[0-9a-zA-Z\-_]+$/, :if => "!name.blank?",
    :message => "は半角英数字、ハイフン、アンダースコアで入力してください。"
  
  def search(params)
    params.each do |n, v|
      next if v.to_s == ''
      
      case n
      when 's_name_or_title'
        self.and_keywords v, :name, :title
      when 's_keyword'
        self.and_keywords v, :name, :title, :body
      end
    end if params.size != 0
    
    return self
  end
end
