# encoding: utf-8
class Sys::Lib::Ldap::Group < Sys::Lib::Ldap::Entry
  cattr_accessor :primary, :filter
  
  @@primary = "ou"
  @@filter  = "(objectClass=top)(objectClass=organizationalUnit)(!(ou=Groups))(!(ou=People))(!(ou=Special*))"
  
  ## Initializer.
  def initialize(connection, attributes = {})
    super
    @primary = @@primary
    @filter  = @@filter
  end
  
  ## Attribute: ou
  def ou
    get(:ou)
  end
  
  ## Attribute: code
  def code
    return nil unless ou
    return ou unless ou =~ /^[0-9a-zA-Z]+[^0-9a-zA-Z]/
    #return ou.gsub(/^([0-9a-zA-Z]+)(.*)/, '\1')
    return ou.gsub(/^([0-9a-zA-Z]+?[0-9]+)(.*)/, '\1')
  end
  
  ## Attribute: name
  def name
    return nil unless ou
    return ou unless ou =~ /^[0-9a-zA-Z]+[^0-9a-zA-Z]/
    #return ou.gsub(/^([0-9a-zA-Z]+)(.*)/, '\2')
    return ou.gsub(/^([0-9a-zA-Z]+?[0-9]+)(.*)/, '\2')
  end
  
  ## Attribute: name(english)
  def name_en
    group_user ? group_user.get('sn;lang-en') : nil
  end
  
  ## Attribute: email
  def email
    group_user ? group_user.get(:mail) : nil
  end
  
  ## Returns the parent group.
  def parent
    tree = get(:dn).split(',')
    return nil if tree.size == 1
    
    filters = []
    tree.each_with_index do |name, idx|
      next if idx == 0
      next if name =~ /^dc=/
      filters << name
    end
    return nil if filters.size == 0
    return search(filters)[0]
  end
  
  ## Returns the parent groups without self.
  def parents
    current = self
    list = []#[current]
    while p = current.parent
      list.unshift(p)
      current = p
    end
    return list
  end
  
  ## Returns the child groups.
  def children
    filter  = nil
    options = {
      :base  => dn,
      :scope => LDAP::LDAP_SCOPE_ONELEVEL
    }
    return search(filter, options)
  end
  
  ## Returns the users.
  def users
    filter  = nil
    options = {
      :base  => dn,
      :scope => LDAP::LDAP_SCOPE_ONELEVEL
    }
    return @connection.user.search(filter, options)
  end
  
  ## Return the group user for group's attributes.
  def group_user
    filter  = "(cn=#{name})"
    options = {
      :base  => dn,
      :scope => LDAP::LDAP_SCOPE_ONELEVEL
    }
    return @connection.user.search(filter, options)[0]
  end
end
