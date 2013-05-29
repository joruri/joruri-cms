# encoding: utf-8
class Sys::Lib::Form::Element::TextArea < Sys::Lib::Form::Element::Base
  def make_tag
    @form.template.text_area_tag(tag_name, @value, @options)
  end
end