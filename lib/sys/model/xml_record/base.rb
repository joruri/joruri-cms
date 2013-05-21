# encoding: utf-8
require "rexml/document"

class Sys::Model::XmlRecord::Base
  @@_model_name   = {}
  @@_column_name  = {}
  @@_primary_key  = {}
  @@_attributes   = {}
  @@_elements     = {}
  @@_node_xpath   = {}
  @_record        = nil
  @_primary_value = nil
  
  def initialize(record, attributes = {})
    @_record = record
    self.attributes = attributes
  end
  
  def self.attributes
    @@_attributes[self] = [] unless @@_attributes[self]
    @@_attributes[self]
  end
  
  def self.attr_accessor(*names)
    super(*names)
    names.each {|name| attributes << name unless attributes.index(name) }
  end
  
  def self.elements
    @@_elements[self] = [] unless @@_elements[self]
    @@_elements[self]
  end
  
  def self.elem_accessor(*names)
    attr_accessor(*names)
    names.each {|name| elements << "#{name}" unless elements.index(name) }
  end
  
  def self.model_name
    @@_model_name[self] ? @@_model_name[self] : ActiveModel::Name.new(self)
  end
  
  def self.set_model_name(name)
    @@_model_name[self] = ActiveModel::Name.new(name.camelize.split(/::/).inject(Object) {|c,name| c.const_get(name) })
  end
  
  def self.primary_key
    @@_primary_key[self]
  end
  
  def self.set_primary_key(name)
    attr_accessor(name) unless attributes.index(name)
    @@_primary_key[self] = name
  end
  
  def self.column_name
    @@_column_name[self]
  end
  
  def self.set_column_name(name)
    @@_column_name[self] = name
  end
  
  def self.node_xpath
    @@_node_xpath[self] ||= ''
  end
  
  def self.set_node_xpath(xpath)
    @@_node_xpath[self] = xpath
  end
  
  def attributes=(_attributes)
    if _attributes.class != REXML::Element
      _attributes.each do |name, val|
        next unless self.class.method_defined?("#{name}=")
        eval("self.#{name} = val")
      end
    else
      _attributes.attributes.each do |name, val|
        next unless self.class.method_defined?("#{name}=")
        eval("self.#{name} = val")
      end
      _attributes.each do |elem|
        next unless elem.class == REXML::Element
        next unless self.class.method_defined?("#{elem.name}=")
        next unless self.class.elements.index(elem.name)
        eval("self.#{elem.name} = []") unless send(elem.name)
        eval("self.#{elem.name} << elem.text")
      end
    end
    self.class.elements.each do |name|
      eval("self.#{name} = []") unless send(name)
    end
  end
  
  def self.human_name
    
  end
  
  def self.human_attribute_name(name, options = {})
    label = I18n.t name, :scope => [:activerecord, :attributes, model_name.to_s.underscore]
    label =~ /^translation missing:/ ? name.to_s.humanize : label
  end
  
  def self.self_and_descendants_from_active_record
    []
  end
  
  def self.find(key, record, options = {})
    xml = eval("record.#{self.column_name}")
    doc = REXML::Document.new(xml)
    doc.add_element 'xml' unless doc.root
    nodes = doc.root.get_elements(node_xpath)
    return key == :all ? [] : nil if nodes.blank?
    
    if key == :all
      items = []
      nodes.each do |node|
        item = self.new(record, node)
        item.set_primary_value
        items << item
      end
      if options[:order] && items.size > 0
        begin
          return items.sort{|a, b| a.send(options[:order]) <=> b.send(options[:order])}
        rescue
          return items
        end
      end
      return items
    elsif key == :first
      item = self.new(record, nodes[0])
      item.set_primary_value
      return item
    end
    
    nodes.each do |node|
      if "#{node.attribute(primary_key)}" == key.to_s
        item = self.new(record, node)
        item.set_primary_value
        return item
      end
    end
    return nil
  end
  
  def new_record?
    @_primary_value == nil
  end
  
  def locale(name)
    label = I18n.t name, :scope => [:activerecord, :attributes, self.class.model_name.to_s.underscore]
    label =~ /^translation missing:/ ? name.to_s.humanize : label
  end
  
  def set_primary_value
    @_primary_value = send(self.class.primary_key) if self.class.primary_key
  end
  
  def attributes
    attr = {}
    self.class.attributes.each {|name| attr[name] = send(name) }
    attr
  end
  
  def errors
    return @_errors if @_errors
    @_errors = ActiveModel::Errors.new(self)
  end
  
  def before_save
    true
  end
  
  def save(validation = true)
    if validation
      return false unless valid?
    end
    return false unless before_save
    eval("@_record.#{self.class.column_name} = build_xml.to_s")
    return false unless @_record.save(:validate => false)
    after_save
    return true
  end
  
  def save!
    false
  end
  
  def after_save
    true
  end
  
  def before_destroy
    true
  end
  
  def destroy
    return false unless before_destroy
    eval("@_record.#{self.class.column_name} = build_xml(:destroy).to_s")
    return false unless @_record.save(:validate => false)
    after_destroy
    return true
  end
  
  def after_destroy
    true
  end
  
  def to_xml_element
    node = REXML::Element.new ::File.basename(self.class.node_xpath)
    attributes.each do |name, val|
      if self.class.elements.index("#{name}")
        arr = val
        if val.class != Array
          arr = []
          val.each {|k,v| arr << v unless v.blank?}
        end
        arr.delete("")
        arr.uniq.each do |v|
          e = REXML::Element.new("#{name}");
          e.add_text(v);
          node << e
        end
      else
        node.add_attributes({"#{name}" => val})
      end
    end
    node
  end
  
  def build_xml(mode = :save)
    xml = eval("@_record.#{self.class.column_name}")
    doc = REXML::Document.new(xml)
    doc.add_element('xml') unless doc.root
    
    xpath = ::File.dirname(self.class.node_xpath)
    unless parent = doc.root.elements[xpath]
      parent = doc.root
      xpath.split('/').each do |name|
        node = parent.add_element(name)
        parent = node
      end
    end
    
    parent.each_element(::File.basename(self.class.node_xpath)) do |e|
      if @_primary_value
        parent.delete_element(e) if e.attribute(self.class.primary_key).to_s == @_primary_value
      elsif !self.class.primary_key
        parent.delete_element(e)
      end
    end
    
    if mode != :destroy
      parent << to_xml_element
    end
    
    doc
  end
  
  include ActiveRecord::Validations
  include ActiveRecord::Validations::ClassMethods
end