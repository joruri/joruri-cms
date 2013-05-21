# encoding: utf-8
module Cms::Lib::Modules
  def self.modules
    Cms::Lib::Modules::ModuleSet.load_modules
  end
  
  def self.find(type, model)
    names = model.to_s.underscore.pluralize.split('/')
    modules.each do |mod|
      next if mod.name.to_s != names[0]
      if type == :content
        mod.contents.each    {|c| return c if c.name.to_s == names[1]}
      elsif type == :node
        mod.directories.each {|c| return c if c.name.to_s == names[1]}
        mod.pages.each       {|c| return c if c.name.to_s == names[1]}
      elsif type == :directory
        mod.directories.each {|c| return c if c.name.to_s == names[1]}
      elsif type == :page
        mod.pages.each       {|c| return c if c.name.to_s == names[1]}
      elsif type == :piece
        mod.pieces.each      {|c| return c if c.name.to_s == names[1]}
      end
    end
    nil
  end
  
  def self.model_name(type, model)
    return nil unless mod = find(type, model)
    mod.full_label
  end
  
  def self.module_name(name)
    modules.each do |mod|
      next if name.to_s != mod.name.to_s
      return mod.label
    end
    nil
  end
  
  def self.contents(model = nil)
    model = model.to_s.underscore.pluralize.split('/')[0] if model
    list = []
    modules.each do |mod|
      next if model && model != mod.name.to_s
      mod.contents.each {|c| list << [c.label, c.model] }
    end
    list
  end
  
  def self.directories(model = nil)
    model = model.to_s.underscore.pluralize.split('/')[0] if model
    list = []
    modules.each do |mod|
      next if model && model != mod.name.to_s
      mod.directories.each {|c| list << [c.label, c.model] }
    end
    list
  end
  
  def self.pages(model = nil)
    model = model.to_s.underscore.pluralize.split('/')[0] if model
    list = []
    modules.each do |mod|
      next if model && model != mod.name.to_s
      mod.pages.each {|c| list << [c.label, c.model] }
    end
    list
  end
  
  def self.pieces(model = nil)
    model = model.to_s.underscore.pluralize.split('/')[0] if model
    list = []
    modules.each do |mod|
      next if model && model != mod.name.to_s
      mod.pieces.each {|c| list << [c.label, c.model] }
    end
    list
  end
end
