# encoding: utf-8
class Sys::Lib::Form::Element::Attachment < Sys::Lib::Form::Element::Base
  def make_tag
    tag  = @form.template.file_field_tag(tag_name + "[file]")
    tag += @form.template.hidden_field_tag(tag_name + "[name]")
    tag += @form.template.hidden_field_tag(tag_name + "[data]")
    if @max_length.present?
      tag += @form.template.content_tag(:span, "（最大#{@max_length} MBまで添付できます。)", class: 'max_length')
    end

    tag.html_safe
  end

  def make_frozen_tag
    tag = ""
    if (file = value[:file]) && file.respond_to?(:original_filename)
      tag += @form.template.hidden_field_tag tag_name + "[name]", file.original_filename
      tag += @form.template.hidden_field_tag tag_name + "[data]", Base64.strict_encode64(file.read)
    elsif value[:name].present?
      tag += @form.template.hidden_field_tag tag_name + "[name]", value[:name]
      tag += @form.template.hidden_field_tag tag_name + "[data]", value[:data]
    end
    tag.html_safe
  end

  def make_frozen_value
    if (file = value[:file]) && file.respond_to?(:original_filename)
      file.original_filename
    elsif value[:name].present?
      value[:name]
    else
      ""
    end
  end

  def element_valid_ext
    @valid_ext
  end


  def self.valid_size_file?(value, max_length)
    return true if value.blank?
    if (file = value[:file]) && file.respond_to?(:original_filename)
      max = max_length
      if max.to_i * (1024**2) < file.size
        return false
      end
    elsif value[:name].present?
      
    else
      return true
    end
    return true
  end


  def self.valid_ext_file?(value, valid_ext)
    return true if value.blank?
    return true if valid_ext.blank?
    allowed_exts = valid_ext.to_s.split(',').map(&:strip).select(&:present?)
    if (file = value[:file]) && file.respond_to?(:original_filename)
      ext = ::File.extname(file.original_filename).downcase.delete('.')
      if allowed_exts.present? && !allowed_exts.include?(ext)
        return false
      end
    elsif value[:name].present?
      ext = ::File.extname(value[:name]).downcase.delete('.')
      if allowed_exts.present? && !allowed_exts.include?(ext)
        return false
      end
    else
      return true
    end
    return true
  end

  def blank_value?
    value.each do |_k, v|
      return false unless v.blank?
    end
    true
  end

end
