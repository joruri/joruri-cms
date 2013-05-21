# encoding: utf-8
class Cms::Piece < ActiveRecord::Base
  include Sys::Model::Base
  include Cms::Model::Base::Piece
  include Cms::Model::Base::Page::Publisher
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::UnidRelation
  include Sys::Model::Rel::Creator
  include Cms::Model::Rel::PieceSetting
  include Cms::Model::Rel::Site
  include Cms::Model::Rel::Concept
  include Cms::Model::Rel::Content
  include Cms::Model::Auth::Concept

  belongs_to :status,   :foreign_key => :state,      :class_name => 'Sys::Base::Status'

  validates_presence_of :concept_id, :state, :model, :name, :title
  validates_uniqueness_of :name, :scope => :concept_id,
    :if => %Q(!replace_page?)
  validates_format_of :name, :with => /^[0-9a-zA-Z\-_]+$/, :if => "!name.blank?",
    :message => "は半角英数字、ハイフン、アンダースコアで入力してください。"
  
  after_save :replace_new_piece
  
  def replace_new_piece
    if state == "public" && rep = replaced_page
      rep.destroy
    end
    return true
  end
  
  def locale(name)
    model = self.class.to_s.underscore
    label = ''
    if model != 'cms/piece'
      label = I18n.t name, :scope => [:activerecord, :attributes, model]
      return label if label !~ /^translation missing:/
    end
    label = I18n.t name, :scope => [:activerecord, :attributes, 'cms/piece']
    return label =~ /^translation missing:/ ? name.to_s.humanize : label
  end
  
  def node_is(node)
    layout = nil
    node = Cms::Node.find(:first, :conditions => {:id => node}) if node.class != Cms::Node
    layout = node.inherited_layout if node
    self.and :id, 'IN', layout.pieces if layout
  end
  
  def css_id
    name.gsub(/-/, '_').camelize(:lower)
  end
  
  def css_attributes
    attr = ''
    
    attr += ' id="' + css_id + '"' if css_id != ''
    
    _cls = 'piece'
    attr += ' class="' + _cls + '"' if _cls != ''
    
    attr
  end
  
  def duplicate(rel_type = nil)
    item = self.class.new(self.attributes)
    item.id            = nil
    item.unid          = nil
    item.created_at    = nil
    item.updated_at    = nil
    item.recognized_at = nil
    item.published_at  = nil
    
    if rel_type == nil
      item.name  = nil
      item.title = item.title.gsub(/^(【複製】)*/, "【複製】")
    elsif rel_type == :replace
      item.state = "closed"
    end
    
    return false unless item.save(:validate => false)
    
    # piece_settings
    settings.each do |setting|
      dupe_setting = Cms::PieceSetting.new(setting.attributes)
      dupe_setting.piece_id   = item.id
      dupe_setting.created_at = nil
      dupe_setting.updated_at = nil
      dupe_setting.save(:validate => false)
    end
    
    if rel_type == :replace
      rel = Sys::UnidRelation.new
      rel.unid     = item.unid
      rel.rel_unid = self.unid
      rel.rel_type = 'replace'
      rel.save
    end
    
    return item
  end
  
  def search(params)
    params.each do |n, v|
      next if v.to_s == ''
      
      case n
      when 's_name_or_title'
        self.and_keywords v, :name, :title
      when 's_keyword'
        self.and_keywords v, :name, :title, :view_title, :body
      end
    end if params.size != 0
    
    return self
  end

end
