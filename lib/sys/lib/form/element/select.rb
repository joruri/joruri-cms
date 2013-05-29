# encoding: utf-8
class Sys::Lib::Form::Element::Select < Sys::Lib::Form::Element::Base
  
  def make_tag
    sopt = %Q(<option value=""></option>)
    select_options.each do |v|
      set   = (value.to_s == v.to_s) ? %Q(selected="selected") : ""
      sopt += %Q(<option value="#{v}" #{set}>#{v}</option>)
    end
    
    @form.template.select_tag(tag_name, sopt.html_safe, @options)
  end
end