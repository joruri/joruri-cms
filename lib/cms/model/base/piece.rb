# encoding: utf-8
module Cms::Model::Base::Piece
  def self.included(mod)
    mod.belongs_to :status, :foreign_key => :state, :class_name => 'Sys::Base::Status'
  end
  
  def states
    [['公開','public'],['非公開','closed']]
  end
  
  def public?
    return state == "public"
  end
  
  def content_name
    return content.name if content
    Cms::Lib::Modules.module_name(:cms)
  end
  
  def model_name(option = nil)
    name = Cms::Lib::Modules.model_name(:piece, model)
    return name.to_s.gsub(/^.*?\//, '') if option == :short
    name
  end
  
  def admin_uri
    controller = model.to_s.underscore.pluralize.gsub(/^(.*?)\//, "\\1/c#{concept_id}/piece_")
    "#{Joruri.admin_uri}/#{controller}/#{id}"
  end
  
  def edit_admin_uri
    "#{admin_uri}/edit"
  end
end