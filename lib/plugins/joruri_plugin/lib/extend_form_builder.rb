# encoding: utf-8

module ActionView
  module Helpers
    module FormHelper   
      def file_field(object_name, method, options = {})
        InstanceTag.new(object_name, method, self, options.delete(:object)).to_input_field_tag("file", options.update({:size => options[:size]}))
      end
    end
  end
end

class ActionView::Helpers::FormBuilder
  
  def error_wrapping(method, tag)
    name = method.gsub(/^.*?\[/, '').gsub(/\]\[/, '_').gsub(/\]$/, '')
    ins  = @template.instance_variable_get("@#{@object_name}")
    err  = ins.errors[name.to_sym]
    return err.size > 0 ? ActionView::Base.field_error_proc.call(tag, ins) : tag
  end
  
  def array_name(method)
    pos = method.index('[').to_i
    pre = pos == 0 ? method : method.slice(0, pos)
    suf = pos == 0 ? "" : method.slice(pos, method.size)
    
    "#{@object_name}[#{pre}]#{suf}"
  end
  
  def array_value(method)
    unless pos = method.to_s.index('[')
      if @template.params[@object_name] && @template.params[@object_name][method]
        return @template.params[@object_name][method]
      else
        return @template.instance_variable_get("@#{@object_name}").send(method)
      end
    end
    pos = pos.to_i
    pre = pos == 0 ? method : method.slice(0, pos)
    suf = pos == 0 ? "" : method.slice(pos, method.size)
    
    arr  = nil
    post = nil
    if @template.params[@object_name] && @template.params[@object_name][pre]
      post = true
      arr = @template.params[@object_name][pre]
    else
      arr = @template.instance_variable_get("@#{@object_name}").send(pre)
    end
    return nil unless arr
    
    value  = nil
    script = "value = arr"
    suf.scan(/\[(.*?)\]/).each do |m|
      script += (post == nil && m[0] =~ /^[0-9]+$/ ? "[#{m[0]}]" : "['#{m[0]}']")
    end
    eval("#{script} rescue nil")
    value.force_encoding(Encoding::UTF_8) if value.respond_to?(:force_encoding)
    
    return value
  end
  
  def array_text_field(method, options = {})
    value  = array_value(method)
    method = array_name(method)
    
    tag = @template.text_field_tag(method, value, options)
    return error_wrapping(method, tag)
  end
  
  def array_text_area(method, options = {})
    value  = array_value(method)
    method = array_name(method)

    tag = @template.text_area_tag(method, value, options)
    return error_wrapping(method, tag)
  end

  def array_select(method, choices, options = {}, html_options = {})
    options[:selected] ||= array_value(method)
    method = array_name(method)
    
    ## choices
    choices.each_with_index {|v,i| choices[i][1] = v[1].to_s }
    choices = @template.options_for_select(choices, options[:selected].to_s)
    if options[:include_blank]
      label = options[:include_blank].class == String ? options[:include_blank] : ''
      choices = %Q(<option value="">#{label}</option>) + choices
      options.delete(:include_blank)
    end
    options.delete(:selected)
    
    tag = @template.select_tag(method, choices.html_safe, options).html_safe
    return error_wrapping(method, tag)
  end
  
  def select_with_tree(method, root, options = {})
    options[:selected] ||= array_value(method)
    method = method.to_s.index('[') ? array_name(method) : "#{@object_name}[#{method}]"
    
    value   = options[:value] || :id
    label   = options[:label] || :name
    order   = options[:order] || :sort_no
    cond    = options[:conditions] || {}
    
    choices = []
    roots = root.to_a
    if roots.size > 0
      iclass  = roots[0].class
      indstr  = '　　'
      down = lambda do |_parent, _indent|
        choices << [(indstr * _indent) + _parent.send(label), _parent.send(value).to_s]
        iclass.find(:all, :conditions => cond.merge({:parent_id => _parent.id}), :order => order).each do |_child|
          down.call(_child, _indent + 1)
        end
      end
      roots.to_a.each {|item| down.call(item, 0)}
      choices = @template.options_for_select(choices, options[:selected].to_s)
      if options[:include_blank]
        label = options[:include_blank].class == String ? options[:include_blank] : ''
        choices = %Q(<option value="">#{label}</option>) + choices
        options.delete(:include_blank)
      end
      options.delete(:selected)
    end
    options.delete(:conditions)
    options.delete(:label)

    choices = '' if choices.empty?
    
    tag  = @template.select_tag(method, choices.html_safe, options).html_safe
    return error_wrapping(method, tag)
  end
  
  def radio_buttons(method, choices, options = {})
    if method.to_s.index('[')
      return array_radio_buttons(method, choices, options)
    end
    h = @template.hidden_field(@object_name, method, :value => '')
    choices.each do |label, value|
      h += radio_button(method, value, options)
      h += %Q(<label for="#{@object_name}_#{method}_#{value}">#{label}</label>\n).html_safe
    end
    h.html_safe
  end
  
  def array_radio_buttons(method, choices, options = {})
    value = array_value(method)
    method = array_name(method)
    
    checked = []
    h = ''
    choices.each do |c|
      name = "#{@object_name}[#{method}][#{c[1]}]"
      id   = method.gsub(/\]/, '').gsub(/\[/, '_') + "_#{c[1]}"
      h += @template.radio_button_tag(method, c[1], (value.to_s == c[1]))
      h += %Q(<label for="#{id}">#{c[0]}</label>\n).html_safe
    end
    h.html_safe
  end
  
  def check_boxes(method, choices, options = {})
    method = method.to_s
    
    checked = []
    if @template.params[@object_name] && @template.params[@object_name][method]
      @template.params[@object_name][method].each {|k, v| checked << k }
    else
      if var = @template.instance_variable_get("@#{@object_name}").send(method)
        checked = var
      end
    end
    
    h = ''
    choices.each do |c|
      c[1] = c[1].to_s
      name = "#{@object_name}[#{method}][#{c[1]}]"
      id   = name.gsub(/\]/, '').gsub(/\[/, '_')
      h += @template.check_box_tag(name, 1, checked.index(c[1]))
      h += %Q(<label for="#{id}">#{c[0]}</label>\n).html_safe
    end
    h.html_safe
  end
end
