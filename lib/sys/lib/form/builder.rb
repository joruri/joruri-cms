# encoding: utf-8
class Sys::Lib::Form::Builder
  attr_accessor :name, :template
  attr_accessor :elements

  @@element_specs = {
    'text_field'   => Sys::Lib::Form::Element::TextField,
    'text_area'    => Sys::Lib::Form::Element::TextArea,
    'select'       => Sys::Lib::Form::Element::Select,
    'radio_button' => Sys::Lib::Form::Element::RadioButton,
    'check_box'    => Sys::Lib::Form::Element::CheckBox,
    'attachment'   => Sys::Lib::Form::Element::Attachment
  }

  def initialize(name, options = {})
    @name     = name
    @template = options[:template]
  end

  def elements
    @elements ||= []
  end

  def element(name)
    elements.each { |e| return e if e.name.to_s == name.to_s }
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
      case e.class.to_s
      when 'Sys::Lib::Form::Element::Attachment'
        values[e.name] = e.value
      else
        values[e.name] = if format == :string
                           e.value_to_string
                         else
                           e.value
                         end

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
        act = e.class.to_s =~ /(select|check|radio)/i ? "選択" : "入力"
        errors.add :base, "#{e.label} を#{act}してください。"
      elsif e.format == 'email' && e.value.present? && !Sys::Lib::Form::FormatChecker.email?(e.value)
        format = 'メールアドレス'
        errors.add :base, "#{e.label} を#{format}の形式で入力してください。"
      elsif e.class.to_s == 'Sys::Lib::Form::Element::Attachment'
        errors.add :base, "#{e.label}は#{e.element_max_length}MB以下にしてください。"  if !Sys::Lib::Form::Element::Attachment.valid_size_file?(e.value, e.element_max_length)
        if !Sys::Lib::Form::Element::Attachment.valid_ext_file?(e.value, e.element_valid_ext)
          allowed_exts = e.element_valid_ext.to_s.split(',').map(&:strip).select(&:present?)
          errors.add :base, "#{e.label}の拡張子は#{allowed_exts.join(', ')}にしてください。"
        end
      end
    end
    errors.empty?
  end

  def freeze
    @frozen = true
    elements.each(&:freeze)
  end
end
