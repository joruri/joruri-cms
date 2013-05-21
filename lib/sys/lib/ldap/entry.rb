# encoding: utf-8
class Sys::Lib::Ldap::Entry
  def initialize(connection, attributes = {})
    attributes.each do |key, val|
      val.each_with_index do |v, k|
        attributes[key][k] = v.force_encoding("utf-8")
      end
    end

    @connection = connection
    @attributes = attributes
    @primary     = nil
    @filter      = nil
  end
  
  def search(filter, options = {})
    filter = "(#{filter.join(')(')})" if filter.class == Array
    filter = "#{filter}(&#{@filter})"
    options[:class] ||= self.class
    return @connection.search(filter, options)
  end
  
  def find(id, options = {})
    filter = "(#{@primary}=#{id})(&#{@filter})"
    options[:class] ||= self.class
    return @connection.search(filter, options)[0]
  end
  
  def attributes
    return @attributes
  end
  
  def get(name, position = 0)
    name = name.to_s
    if position == :all
      return @attributes[name] ? @attributes[name] : []
    elsif @attributes[name]
      return @attributes[name][position]
    else
      return nil
    end
  end
  
  def dn
    get(:dn)
  end
end
