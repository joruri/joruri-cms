# encoding: utf-8
class Cms::Lib::Modules::ModuleSet
  @@modules = nil
  
  attr_accessor :name
  attr_accessor :label
  attr_accessor :contents
  attr_accessor :directories
  attr_accessor :pages
  attr_accessor :pieces
  
  def self.load_modules
    return @@modules if @@modules
    Dir::entries('config/modules').sort.each do |mod|
      next if mod =~ /^\.+$/
      file = "#{Rails.root}/config/modules/#{mod}/module.rb"
      load(file) if FileTest.exists?(file)
    end
    @@modules
  end
  
  def self.draw(name, label, &block)
    @@modules = [] unless @@modules
    yield mod = self.new
    mod.name  = name
    mod.label = label
    @@modules << mod
  end
  
  def initialize
    @contents    = []
    @directories = []
    @pages       = []
    @pieces      = []
  end
  
  def content(name, label)
    @contents << Model.new(self, name, label)
  end
  
  def directory(name, label)
    label = "ディレクトリ/#{label}" if label != 'ディレクトリ'
    @directories << Model.new(self, name, label, :directory)
  end
  
  def page(name, label)
    label = "ページ/#{label}"
    @pages << Model.new(self, name, label, :page)
  end
  
  def piece(name, label)
    @pieces << Model.new(self, name, label)
  end
  
  class Model
    attr_accessor :name
    attr_accessor :label
    attr_accessor :type
    
    def initialize(mod, name, label, type = nil)
      @mod = mod
      self.name  = name
      self.label = label
      self.type  = type
    end
    
    def model
      "#{@mod.name}/#{name}".singularize.camelize
    end
    
    def full_label
      "#{@mod.label}/#{label}"
    end
  end
end
