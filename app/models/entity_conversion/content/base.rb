# encoding: utf-8
class EntityConversion::Content::Base < Cms::Content
  
  has_many :units, :foreign_key => :content_id, :class_name => 'EntityConversion::Unit',
    :dependent => :destroy
  has_many :logs, :foreign_key => :content_id, :class_name => 'EntityConversion::Log',
    :dependent => :destroy

end