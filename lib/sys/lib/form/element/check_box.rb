# encoding: utf-8
class Sys::Lib::Form::Element::CheckBox < Sys::Lib::Form::Element::Base
  def value_to_string
    return nil if @value.blank?
    values = @value.collect{|k,v| v}
    values.delete('')
    values = values.uniq
    values.join("\n")
  end
  
  def make_tag
    values = @value.blank? ? [] : value.collect{|k,v| v}.uniq
    
    tag = %Q(<div #{attributes_string}>)
    select_options.each_with_index do |v, k|
      eopt = values.index(v) ? {:checked => true} : {}
      tag += %Q(<div class="element">)
      tag += @form.template.check_box(tag_name, k, eopt, v, "")
      tag += %Q(<label for="#{tag_id(k)}">#{v}</label>)
      tag += "</div>"
    end
    tag += "</div>"
    tag.html_safe
  end
  
  def make_frozen_tag
    return "" if @value.blank?
    
    tag = ""
    @value.each do |k, v|
      next if v.blank?
      tag += @form.template.hidden_field_tag("#{tag_name}[#{k}]", v)
    end
    tag.html_safe
  end
  
  def make_frozen_value
    return "" if @value.blank?
    values = value.collect{|k,v| v}.uniq
    
    tag = ""
    select_options.each_with_index do |v, k|
      if value.index(v)
        tag += ERB::Util.html_escape(v)
        tag += "\n"
      end
    end
    tag
  end
  
  def blank_value?
    value.each do |k,v|
      return false if !v.blank?
    end
    true
  end
end