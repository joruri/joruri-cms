# encoding: utf-8
class Sys::Lib::Form::Element::RadioButton < Sys::Lib::Form::Element::Base
  
  def make_tag
    tag = %Q(<div #{attributes_string}>)
    select_options.each_with_index do |v, k|
      eopt = {:id => tag_id(k)}
      chk  = (!value.blank? && value.to_s == v.to_s)
      tag += %Q(<div class="element">)
      tag += @form.template.radio_button_tag(tag_name, v, chk, eopt)
      tag += %Q(<label for="#{tag_id(k)}">#{v}</label>)
      tag += "</div>"
    end
    tag += "</div>"
    tag.html_safe
  end
end