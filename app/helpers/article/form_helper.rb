# encoding: utf-8
module Article::FormHelper
  def article_category_form(form, options = {})
    item = instance_variable_get("@#{form.object_name}")
    locals = {:f => form, :item => item}.merge(options)
    render :partial => 'article/admin/_partial/categories/form', :locals => locals
  end
  
  def article_attribute_form(form, options = {})
    item = instance_variable_get("@#{form.object_name}")
    locals = {:f => form, :item => item}.merge(options)
    render :partial => 'article/admin/_partial/attributes/form', :locals => locals
  end
  
  def article_area_form(form, options = {})
    item = instance_variable_get("@#{form.object_name}")
    locals = {:f => form, :item => item}.merge(options)
    render :partial => 'article/admin/_partial/areas/form', :locals => locals
  end
  
  def article_rel_doc_form(form, options = {})
    item = instance_variable_get("@#{form.object_name}")
    locals = {:f => form, :item => item}.merge(options)
    render :partial => 'article/admin/_partial/rel_docs/form', :locals => locals
  end
  
  def article_tag_form(form, options = {})
    item = instance_variable_get("@#{form.object_name}")
    locals = {:f => form, :item => item}.merge(options)
    render :partial => 'article/admin/_partial/tags/form', :locals => locals
  end
end
