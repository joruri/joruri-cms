# encoding: utf-8
class Cms::Model::Tool::Export < ActiveRecord::Base
  self.table_name = "cms_concepts" #dummy
  
  attr_accessor :concept_id
  attr_accessor :target
  
  validates_presence_of :concept_id
  
  # empty methods
  def seve; end
  def destroy; end
end