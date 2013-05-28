# encoding: utf-8
module EntityConversion::Lib::Convertor::Production
  
  def self.extended(mod)
  end
  
  def convert_new(unit)
    if unit.parent
      parent_id = unit.parent.id
    elsif parent = unit.new_parent
      parent_id = Sys::Group.uncached { Sys::Group.find_by_code(parent.code).id }
    end
    
    group = Sys::Group.new({
      :state       => "enabled",
      :parent_id   => parent_id,
      :level_no    => unit.level_no,
      :code        => unit.code,
      :name        => unit.name,
      :name_en     => unit.name_en,
      :ldap        => unit.ldap,
      :sort_no     => unit.sort_no,
      :web_state   => unit.web_state,
      :layout_id   => unit.layout_id,
      :email       => unit.email,
      :tel         => unit.tel,
      :outline_uri => unit.outline_uri,
    })
    if !group.save
      raise group.errors.full_messages.join(", ")
    end
  end
  
  def convert_edit(unit, group)
    group.attributes = {
      :ldap_version => nil,
      :code         => unit.code,
      :name         => unit.name,
      :name_en      => unit.name_en,
      :ldap         => unit.ldap,
      :sort_no      => unit.sort_no,
      :web_state    => unit.web_state,
      :layout_id    => unit.layout_id,
      :email        => unit.email,
      :tel          => unit.tel,
      :outline_uri  => unit.outline_uri,
    }
    if !group.save
      raise group.errors.full_messages.join(", ")
    end
  end
  
  def convert_move(unit, group)
    if move = unit.move
      new_id = move.id
    elsif move = unit.new_move
      new_id = Sys::Group.uncached { Sys::Group.find_by_code(move.code).id }
    end
    group.destroy if group.id != new_id
  end
  
  def convert_end(unit, group)
    group.destroy
  end
  
  def replace_group_id_save(item, fields, old_id, new_id)
    fields.each do |field|
      next if item.send(field).blank?
      value = item.send(field)
      if value.is_a?(Fixnum)
        value = new_id
      elsif value.is_a?(String)
        value = value.gsub(/((^| )#{old_id}( |$))/, '\\2' + "#{new_id}" + '\\3')
      end
      item.send("#{field}=", value)
    end
    @logs << "Error: #{item.errors.full_messages.join(', ')}" if !item.save(:validate => false)
  end
  
  def replace_texts_save(item, fields, texts)
    fields.each do |field|
      next if item.send(field).blank?
      value = item.send(field)
      texts.each {|src, dst| value = value.gsub(/#{Regexp.escape(src)}/, dst) }
      item.send("#{field}=", value)
    end
    @logs << "Error: #{item.errors.full_messages.join(', ')}" if !item.save(:validate => false)
  end
  
end