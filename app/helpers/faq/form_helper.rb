# encoding: utf-8
module Faq::FormHelper
  def faq_category_form(form, options = {})
    item = instance_variable_get("@#{form.object_name}")
    locals = {:f => form, :item => item}.merge(options)
    render :partial => 'faq/admin/_partial/categories/form', :locals => locals
  end
  
  def faq_rel_doc_form(form, options = {})
    item = instance_variable_get("@#{form.object_name}")
    locals = {:f => form, :item => item}.merge(options)
    render :partial => 'faq/admin/_partial/rel_docs/form', :locals => locals
  end
  
  def faq_tag_form(form, options = {})
    item = instance_variable_get("@#{form.object_name}")
    locals = {:f => form, :item => item}.merge(options)
    render :partial => 'faq/admin/_partial/tags/form', :locals => locals
  end
end
