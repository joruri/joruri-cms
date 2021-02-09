# encoding: utf-8
class Sys::Lib::Form::Element::Base
  attr_accessor :name, :label, :value, :options
  attr_accessor :message, :required, :select_options
  attr_accessor :format

  def initialize(form, name, label, options = {})
    @form     = form
    @name     = name
    @label    = label
    @options  = options

    @message  = options[:message]
    @options.delete(:message)

    @max_length = options[:max_length]
    @options.delete(:max_length)

    @valid_ext = options[:valid_ext]
    @options.delete(:valid_ext)

    @required = options[:required]
    @options.delete(:required)

    @format  = options[:format]
    @options.delete(:format)

    @select_options = []
    options[:options].split(/\n/).each do |v|
      @select_options << v unless (v = v.strip).blank?
    end if options[:options]
    @options.delete(:options)
  end

  def value_to_string
    value.to_s
  end

  def element_max_length
    @max_length
  end

  def element_valid_ext
    @valid_ext
  end

  def attributes_string
    attr = []
    @options.each { |k, v| attr << %(#{k}="#{v}") unless v.blank? }
    attr = attr.empty? ? nil : attr.join(' ')
  end

  def tag_id(key = nil)
    key.nil? ? "#{@form.name}_#{@name}" : "#{@form.name}_#{@name}_#{key}"
  end

  def tag_name
    "#{@form.name}[#{@name}]"
  end

  def tag
    @frozen == true ? make_frozen_tag + make_frozen_value : make_tag
  end

  def make_tag
    nil
  end

  def make_frozen_tag
    @form.template.hidden_field_tag(tag_name, @value)
  end

  def make_frozen_value
    ERB::Util.html_escape(@value).gsub(/\r\n|\r|\n/, '<br />').html_safe
  end

  def freeze
    @frozen = true
  end

  def blank_value?
    value.blank?
  end
end
