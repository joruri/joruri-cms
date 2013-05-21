# encoding: utf-8
module Cms::EmbeddedFileHelper
  
  def embedded_file_form(form, options = {})
    item = instance_variable_get("@#{form.object_name}")
    locals = {:f => form, :item => item, :name => :file_id}.merge(options)
    render :partial => 'cms/admin/_partial/embedded_file/form', :locals => locals
  end
  
  def embedded_file_view(item, options = {})
    locals = {:item => item, :name => :file_id}.merge(options)
    render :partial => 'cms/admin/_partial/embedded_file/view', :locals => locals
  end
  
  def embedded_file_path(item)
    cms_embedded_file_path(item.id, item.name, :_t => item.updated_at.to_i)
  end
  
  def embedded_thumbnail_path(item)
    cms_embedded_thumbnail_path(item.id, item.name, :_t => item.updated_at.to_i)
  end
  
  def public_embedded_file_path(item)
    "/_emfiles/#{Util::String::CheckDigit.add_digit(format('%07d', item.id))}/#{item.name}"
  end
  
  def public_embedded_thumbnail_path(item)
    "/_emfiles/#{Util::String::CheckDigit.add_digit(format('%07d', item.id))}/thumb/#{item.name}"
  end
end