# encoding: utf-8
module Tourism::FormHelper
  def tourism_genres_form(form, options = {})
    item = instance_variable_get("@#{form.object_name}")
    locals = {:f => form, :item => item}.merge(options)
    render :partial => 'tourism/admin/_partial/genres/form', :locals => locals
  end
  
  def tourism_areas_form(form, options = {})
    item = instance_variable_get("@#{form.object_name}")
    locals = {:f => form, :item => item}.merge(options)
    render :partial => 'tourism/admin/_partial/areas/form', :locals => locals
  end
  
  def tourism_rel_spots_form(form, options = {})
    item = instance_variable_get("@#{form.object_name}")
    locals = {:f => form, :item => item}.merge(options)
    render :partial => 'tourism/admin/_partial/rel_spots/form', :locals => locals
  end
  
  def tourism_spot_tags_form(form, options = {})
    item = instance_variable_get("@#{form.object_name}")
    locals = {:f => form, :item => item}.merge(options)
    render :partial => 'tourism/admin/_partial/spot_tags/form', :locals => locals
  end
  
  def tourism_genre_and_spot_form(form, options = {})
    item = instance_variable_get("@#{form.object_name}")
    locals = {:f => form, :item => item}.merge(options)
    render :partial => 'tourism/admin/_partial/genre_and_spot/form', :locals => locals
  end
  
  def tourism_genre_and_spot_view(item)
    locals = {:item => item}
    render :partial => 'tourism/admin/_partial/genre_and_spot/view', :locals => locals
  end
  
  def tourism_area_form(form, options = {})
    item = instance_variable_get("@#{form.object_name}")
    locals = {:f => form, :item => item}.merge(options)
    render :partial => 'tourism/admin/_partial/area/form', :locals => locals
  end
  
  def tourism_area_view(item)
    locals = {:item => item}
    render :partial => 'tourism/admin/_partial/area/view', :locals => locals
  end
end
