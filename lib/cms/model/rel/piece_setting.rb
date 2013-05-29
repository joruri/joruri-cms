# encoding: utf-8
module Cms::Model::Rel::PieceSetting
  def self.included(mod)
    mod.has_many   :settings, :foreign_key => :piece_id,   :class_name => 'Cms::PieceSetting',
      :order => :sort_no, :dependent => :destroy
    
    mod.after_save :save_settings
  end

  def in_settings
    unless @in_settings
      values = {}
      settings.each do |st|
        if st.sort_no
          values[st.name] ||= {}
          values[st.name][st.sort_no] = st.value
        else
          values[st.name] = st.value
        end
      end
      @in_settings = values
    end
    @in_settings
  end
  
  def in_settings=(values)
    @in_settings = values
  end
  
  def new_setting(name = nil)
    Cms::PieceSetting.new({:piece_id => id, :name => name.to_s})
  end
  
  def setting_value(name, default_value = nil)
    st = settings.find(:first, :conditions => {:name => name.to_s})
    return default_value unless st
    return st.value.blank? ? default_value : st.value
  end
  
  def save_settings
    in_settings.each do |name, value|
      name = name.to_s
      
      if !value.is_a?(Hash)
        st = settings.find(:first, :conditions => ["name = ?", name]) || new_setting(name)
        st.value   = value
        st.sort_no = nil
        st.save if st.changed?
        next
      end
      
      _settings = settings.find(:all, :conditions => ["name = ?", name])
      value.each_with_index do |data, idx|
        st = _settings[idx] || new_setting(name)
        st.sort_no = data[0]
        st.value   = data[1]
        st.save if st.changed?
      end
      (_settings.size - value.size).times do |i|
        idx = value.size + i - 1
        _settings[idx].destroy
        _settings.delete_at(idx)
      end
    end
    return true
  end
end