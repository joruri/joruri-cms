# encoding: utf-8
class Cms::DataFileNode < ActiveRecord::Base
  include Sys::Model::Base
  include Cms::Model::Base::Page
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::Creator
  include Cms::Model::Rel::Site
  include Cms::Model::Rel::Concept
  include Cms::Model::Auth::Concept
  
  has_many :files, :foreign_key => :node_id, :class_name => 'Cms::DataFile', :primary_key => :id
  
  validates_presence_of :concept_id, :name
  validates_uniqueness_of :name, :scope => :concept_id
  validate :validate_name
  
  after_destroy :remove_files
  
  def label(separator = " : ")
    label = name
    unless title.blank?
      label += "#{separator}#{title}"
    end
    label
  end
  
  def validate_name
    if !name.blank?
      if name !~ /^[0-9a-zA-Z_\-]+$/
        errors.add :name, "は半角英数字を入力してください。"
      end
    end
  end
  
  def search(params)
    params.each do |n, v|
      next if v.to_s == ''
      
      case n
      when 's_keyword'
        self.and_keywords v, :name, :title
      end
    end if params.size != 0
    
    return self
  end

private
  def remove_files
    files.each {|file| file.destroy }
    return true
  end
end
