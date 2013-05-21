# encoding: utf-8
class Article::Category < ActiveRecord::Base
  include Sys::Model::Base
  include Cms::Model::Base::Page
  include Cms::Model::Base::Page::Publisher
  include Cms::Model::Base::Page::TalkTask
  include Sys::Model::Tree
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::Creator
  include Cms::Model::Rel::Concept
  include Cms::Model::Auth::Content
  
  belongs_to :status,  :foreign_key => :state,      :class_name => 'Sys::Base::Status'
  belongs_to :parent,  :foreign_key => :parent_id,  :class_name => "#{self}"
  belongs_to :content,  :foreign_key => :content_id, :class_name => 'Cms::Content'
  belongs_to :layout,  :foreign_key => :layout_id,  :class_name => "Cms::Layout"
  
  has_many   :children, :foreign_key => :parent_id , :class_name => "#{self}",
    :order => :sort_no, :dependent => :destroy
    
  validates_presence_of :state, :parent_id, :name, :title
  validates_uniqueness_of :name, :scope => [:content_id]
  
  def self.root_items(conditions = {})
    conditions = conditions.merge({:parent_id => 0, :level_no => 1})
    self.find(:all, :conditions => conditions, :order => :sort_no)
  end
  
  def public_path
    "#{content.public_path}/categories/#{name}/index.html"
  end
  
  def public_children
    item = self.class.new.public
    item.and :content_id, content_id
    item.and :parent_id, id
    item.find(:all, :order => :sort_no)
  end
  
  def node_label(options = {})
    labels = []
    parents_tree.each {|c| labels << c.title }
    labels.join('/')
  end
  
  def bread_crumbs(node)
    crumbs = []
    node.routes.each do |r|
      c = []
      r.each {|i| c << [i.title, i.public_uri] }
      
      uri = c.last[1] || '/'
      parents_tree.each do |p|
        c << [p.title, "#{uri}#{p.name}/"]
      end
      
      crumbs << c
    end
    Cms::Lib::BreadCrumbs.new(crumbs)
  end
end
