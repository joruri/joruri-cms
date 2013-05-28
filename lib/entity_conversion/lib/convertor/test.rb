# encoding: utf-8
module EntityConversion::Lib::Convertor::Test
  
  def self.extended(mod)
  end
  
  def convert_new(unit)
    if unit.parent
      parent_id = unit.parent.id
    elsif parent = unit.new_parent
      raise "group is not exists #{parent.name}" unless @new_codes[parent.code]
      parent_id = 0
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
    
    if @new_codes[group.code]
      raise "group is already exists ##{group.code}"
    elsif !group.valid?
      raise group.errors.full_messages.join(", ")
    end
    
    @new_codes[group.code] = true
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
    
    if @new_codes[group.code]
      raise "group is already exists ##{group.code}"
    elsif !group.valid?
      raise group.errors.full_messages.join(", ")
    end
    
    @new_codes[group.code]  = true
  end
  
  def convert_move(unit, group)
    if @end_ids[group.id]
      raise "group is not exists #{group.name}"
    elsif move = unit.move
      raise "group is not exists #{group.name} > #{move.name}" if @end_ids[move.id]
    elsif move = unit.new_move
      raise "group is not exists #{group.name} > #{move.name}" if !@new_codes[move.code]
    else
      raise "move: group is not exists #{group.name}"
    end
    
    @end_ids[group.id] = true
  end
  
  def convert_end(unit, group)
    if @end_ids[group.id]
      raise "group is not exists #{group.name}"
    end
    
    @end_ids[group.id] = true
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
    if !item.valid?
      return if item.errors.size == 1 && item.errors.keys[0].to_s =~/file/
      raise item.errors.full_messages.join(", ")
    end
  end
  
  def replace_texts_save(item, fields, texts)
    fields.each do |field|
      next if item.send(field).blank?
      value = item.send(field).clone
      texts.each {|src, dst| value = value.gsub(/#{Regexp.escape(src)}/, dst) }
      item.send("#{field}=", value)
    end
    if !item.valid?
      return if item.errors.size == 1 && item.errors.keys[0].to_s =~/file/
      raise item.errors.full_messages.join(", ")
    end
  end
  
end