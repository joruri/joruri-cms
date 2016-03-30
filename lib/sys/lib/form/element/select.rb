# encoding: utf-8
class Sys::Lib::Form::Element::Select < Sys::Lib::Form::Element::Base
  def make_tag
    sopt = %(<option value=""></option>)
    select_options.each do |v|
      set   = (value.to_s == v.to_s) ? %(selected="selected") : ''
      sopt += %(<option value="#{v}" #{set}>#{v}</option>)
    end

    @form.template.select_tag(tag_name, sopt.html_safe, @options)
  end
end
