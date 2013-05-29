# encoding: utf-8
class Sys::Model::ValidationModel::Base
  include Sys::Model::ValidationModel
  
  def self.model_namea
    
  end
  
  def self.human_name
    nil
  end
  
  def self.human_attribute_name(name, options = {})
    label = I18n.t name, :scope => [:activerecord, :attributes, model_name.to_s.underscore]
    label =~ /^translation missing:/ ? name.to_s.humanize : label
  end
  
  def self.self_and_descendants_from_active_record
    []
  end
  
  def locale(name)
    label = I18n.t name, :scope => [:activerecord, :attributes, self.class.model_name.to_s.underscore]
    label =~ /^translation missing:/ ? name.to_s.humanize : label
  end
  
  def new_record?
    defined?(@new_record) && @new_record
  end
  
  def readonly?
    defined?(@readonly) && @readonly == true
  end
  
  def create_or_update
    #raise ReadOnlyRecord if readonly?
    result = new_record? ? create : update
    result != false
  end
  
  def save
    create_or_update
  end
  
  def save!
    nil
  end
  
  def create
    nil
  end
  
  def update
    nil
  end
  
  include ActiveRecord::Validations
  include ActiveRecord::Validations::ClassMethods
end