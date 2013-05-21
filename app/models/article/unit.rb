# encoding: utf-8
class Article::Unit < Sys::Group
  include Cms::Model::Base::Page
  include Cms::Model::Base::Page::Publisher
  include Cms::Model::Base::Page::TalkTask
  
  belongs_to :parent, :foreign_key => 'parent_id', :class_name => "#{self}"
  
  has_many   :children, :foreign_key => :parent_id , :class_name => "#{self}",
    :order => :sort_no, :dependent => :destroy
  
  def self.find_departments(conditions = {})
    conditions = conditions.merge({:level_no => 2})
    self.find(:all, :conditions => conditions, :order => :sort_no)
  end
  
  def self.find_sections(conditions = {})
    conditions = conditions.merge({:level_no => 3})
    self.find(:all, :conditions => conditions, :order => :sort_no)
  end
  
  def self.root_item
    item = self.new
    item.and :parent_id, 0
    item.find(:first, :order => :sort_no)
  end
  
  def public_path(content)
    "#{content.public_path}/units/#{name}/index.html"
  end
  
  def name
    read_attribute(:name_en)
  end
  
  def title
    read_attribute(:name)
  end
  
  def node_label(options = {})
    labels = []
    parents_tree.each {|c| labels << c.title if c.level_no != 1 }
    labels.join('/')
  end
  
  def public
    self.and :web_state, 'public'
    self
  end
  
  def public_children
    item = self.class.new.public
    item.and :parent_id, id
    item.find(:all, :order => :sort_no)
  end
  
  def bread_crumbs(node)
    crumbs = []
    node.routes.each do |r|
      c = []
      r.each {|i| c << [i.title, i.public_uri] }
      
      uri = c.last[1] || '/'
      parents_tree.each do |p|
        c << [p.title, "#{uri}#{p.name}/"] if p.level_no != 1
      end
      
      crumbs << c
    end
    Cms::Lib::BreadCrumbs.new(crumbs)
  end
  
  def editable?
    return Core.user.has_auth?(:designer)
  end
end
