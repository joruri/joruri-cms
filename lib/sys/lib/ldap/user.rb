# encoding: utf-8
class Sys::Lib::Ldap::User < Sys::Lib::Ldap::Entry
  cattr_accessor :primary, :filter
  
  @@primary = "uid"
  @@filter  = "(&(objectClass=top)(objectClass=organizationalPerson))"
  
  ## Initializer.
  def initialize(connection, attributes = {})
    super
    @primary = @@primary
    @filter  = @@filter
  end
  
  ## Attribute: uid
  def uid
    get(:uid)
  end
  
  ## Attribute: name
  def name
    get(:cn)
  end
  
  ## Attribute: english name
  def name_en
    "#{get('sn;lang-en')} #{get('givenName;lang-en')}".strip
  end
  
  ## Attribute: email
  def email
    get(:mail)
  end
end
