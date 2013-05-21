# encoding: utf-8
class Cms::Concept < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::Creator
  include Sys::Model::Rel::Role
  include Sys::Model::Tree
  include Sys::Model::Base::Page
  include Sys::Model::Auth::Manager
  
  belongs_to :status, :foreign_key => :state,
    :class_name => 'Sys::Base::Status'
  has_many :children, :foreign_key => :parent_id, :order => :name,
    :class_name => 'Cms::Concept', :dependent => :destroy
  has_many :layouts , :foreign_key => :concept_id, :order => :name,
    :class_name => 'Cms::Layout', :dependent => :destroy
  has_many :pieces  , :foreign_key => :concept_id, :order => :name,
    :class_name => 'Cms::Piece', :dependent => :destroy
  has_many :contents , :foreign_key => :concept_id,
    :class_name => 'Cms::Content', :dependent => :destroy
  has_many :data_files , :foreign_key => :concept_id,
    :class_name => 'Cms::DataFile', :dependent => :destroy
  has_many :data_file_nodes , :foreign_key => :concept_id,
    :class_name => 'Cms::DataFileNode', :dependent => :destroy
  
  validates_presence_of :site_id, :state, :level_no, :name
  
  def validate
    if id != nil && id == parent_id
      errors.add :parent_id, :invalid
    end
  end
  
  def targets
    [['現在のコンセプトから','current'], ['すべてのコンセプトから','all']]
  end
  
  def readable_children
    item = Cms::Concept.new
    item.has_priv(:read, :user => Core.user)
    item.and :parent_id, (id || 0)
    item.and :site_id, Core.site.id
    item.and :state, 'public'
    item.find(:all, :order => :sort_no)
  end
  
  def parent
    self.class.find_by_id(parent_id)
  end

  #contentsメソッドがあるとサイトの削除で delete_all エラーが出る
#  def contents
#    Cms::Content.find(:all, :conditions => {:concept_id => id}, :order => :name)
#  end
  
  def self.find_by_path(path)
    return nil if path.to_s == ''
    parent_id = 0
    item = nil
    path.split('/').each do |name|
      cond = {:parent_id => parent_id, :name => name}
      unless item = self.find(:first, :conditions => cond, :order => :id)
        return nil
      end
      parent_id = item.id
    end
    return item
  end
  
  def path
    path = name
    id = self.parent_id
    lo = 0
    while item = Cms::Concept.find_by_id(id) do
      id = item.parent_id
      path = item.name + '/' + path
      lo += 1
      if lo > 100
        path = nil
        break
      end
    end if id > 0
    path
  end
  
  def make_candidates(args1, args2)
    choiced = []
    choices = []
    down    = lambda do |p, i|
      next if choiced[p.id] != nil
      choiced[p.id] = true
      
      choices << [('　　' * i) + p.name, p.id]
      self.class.find(:all, eval("{#{args2}}")).each do |c|
        down.call(c, i + 1)
      end
    end
    
    self.class.find(:all, eval("{#{args1}}")).each {|item| down.call(item, 0) }
    return choices
  end
  
  def candidate_parents
    args1  = %Q( :conditions => ["id != ? AND site_id = ? AND level_no = 1", id, Core.site.id], )
    args1  = %Q( :conditions => ["site_id = ? AND level_no = 1", Core.site.id], ) unless id
    args1 += %Q( :order => :sort_no)
    args2  = %Q( :conditions => ["id != ? AND parent_id = ?", id, p.id], )
    args2  = %Q( :conditions => ["parent_id = ?", p.id], ) if new_record?
    args2 += %Q( :order => :sort_no)
    make_candidates(args1, args2)
  end
end
