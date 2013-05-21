# encoding: utf-8
class Sys::Lib::Form::Builder
  attr_accessor :name, :template
  attr_accessor :elements
  
  @@element_specs = {
    'text_field'   => Sys::Lib::Form::Element::TextField,
    'text_area'    => Sys::Lib::Form::Element::TextArea,
    'select'       => Sys::Lib::Form::Element::Select,
    'radio_button' => Sys::Lib::Form::Element::RadioButton,
    'check_box'    => Sys::Lib::Form::Element::CheckBox
  }
  
  def initialize(name, options = {})
    @name     = name
    @template = options[:template]
  end
  
  def elements
    @elements ||= []
  end
  
  def element(name)
    elements.each {|e| return e if e.name.to_s == name.to_s}
    nil
  end
  
  def add_element(type, name, label, options = {})
    element = make_element(type, name, label, options)
    elements << element
    element
  end
  
  def make_element(type, name, label, options = {})
    @@element_specs[type].new(self, name, label, options)
  end
  
  def submit_values=(values)
    return false unless values
    values.each do |k, v|
      if e = element(k)
        e.value = v
      end
    end
  end
  
  def values(format = nil)
    values = {}
    elements.each do |e|
      if format == :string
        values[e.name] = e.value_to_string
      else
        values[e.name] = e.value
      end
    end
    values
  end
  
  def errors
    @errors ||= ActiveModel::Errors.new(self)
  end
  
  def valid?
    elements.each do |e|
      if e.required == true && e.blank_value?
        errors.add :base, "#{e.label} を入力してください。"
      end
    end
    return errors.size == 0
  end
  
  def freeze
    @frozen = true
    elements.each {|e| e.freeze}
  end
end