# encoding: utf-8
class Faq::Doc < ActiveRecord::Base
  include Sys::Model::Base
  include Cms::Model::Base::Page
  include Cms::Model::Base::Page::Publisher
  include Cms::Model::Base::Page::TalkTask
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::UnidRelation
  include Sys::Model::Rel::Creator
  include Cms::Model::Rel::Inquiry
  include Sys::Model::Rel::Recognition
  include Sys::Model::Rel::Task
  include Cms::Model::Rel::Map
  include Sys::Model::Rel::File
  include Sys::Model::Rel::EditableGroup
  include Faq::Model::Rel::Doc::Tag
  include Faq::Model::Rel::Doc::Rel
  include Faq::Model::Rel::Doc::Unit
  include Faq::Model::Rel::Doc::Category
  include Cms::Model::Auth::Concept
  include Sys::Model::Auth::EditableGroup

  belongs_to :content,        :foreign_key => :content_id,        :class_name => 'Faq::Content::Doc'
  belongs_to :status,         :foreign_key => :state,             :class_name => 'Sys::Base::Status'
  belongs_to :notice_status,  :foreign_key => :notice_state,      :class_name => 'Sys::Base::Status'
  belongs_to :recent_status,  :foreign_key => :recent_state,      :class_name => 'Sys::Base::Status'
  belongs_to :language,       :foreign_key => :language_id,       :class_name => 'Sys::Language'

  attr_accessor :concept_id, :layout_id
  
  validates_presence_of :title
  validates_uniqueness_of :name, :scope => :content_id,
    :if => %Q(!replace_page?)
  
  validates_presence_of :state, :recent_state, :language_id, :question, :body,
    :if => %Q(state == "recognize")
  validates_length_of :title,  :maximum => 200,
    :if => %Q(state == "recognize")
  validates_length_of :question,  :maximum => 100000,
    :if => %Q(state == "recognize")
  validates_length_of :body,  :maximum => 100000,
    :if => %Q(state == "recognize")
  validates_length_of :mobile_body,  :maximum => 10000,
    :if => %Q(state == "recognize")
  validate :validate_word_dictionary,
    :if => %Q(state == "recognize")
  validate :validate_platform_dependent_characters,
    :if => %Q(state == "recognize")
  validate :validate_inquiry,
    :if => %Q(state == "recognize")
  validate :validate_recognizers,
    :if => %Q(state == "recognize")
  
  before_save :check_digit
  before_save :modify_attributes
  
  def concept
    concept_id ? Cms::Concept.find_by_id(concept_id) : nil
  end
  
  def layout
    layout_id ? Cms::Layout.find_by_id(layout_id) : nil
  end
  
  def validate_word_dictionary
    dic = content.setting_value(:word_dictionary)
    return if dic.blank?
    
    words = []
    dic.split(/\r\n|\n/).each do |line|
      next if line !~ /,/
      data = line.split(/,/)
      words << [data[0].strip, data[1].strip]
    end
    
    if !question.blank?
      words.each {|src, dst| self.question = question.gsub(src, dst) }
    end
    if !body.blank?
      words.each {|src, dst| self.body = body.gsub(src, dst) }
    end
    if !mobile_body.blank?
      words.each {|src, dst| self.mobile_body = mobile_body.gsub(src, dst) }
    end
  end
  
  def validate_platform_dependent_characters
    [:title, :body, :mobile_body, :question].each do |attr|
      if chars = Util::String.search_platform_dependent_characters(send(attr))
        errors.add attr, :platform_dependent_characters, :chars => chars
      end
    end
  end
  
  def states
    s = [['下書き保存','draft'],['承認待ち','recognize']]
    s << ['公開保存','public'] if Core.user.has_auth?(:manager)
    s
  end

  def agent_states
    [['全てに表示',''], ['PCのみ表示','pc'], ['携帯のみ表示','mobile']]
  end
  
  def agent_status
    agent_states.each do |name, id|
      return Sys::Base::Status.new(:id => id, :name => name) if agent_state.to_s == id
    end
    nil
  end
  
  def notice_states
    [['表示','visible'],['非表示','hidden']]
  end

  def recent_states
    [['表示','visible'],['非表示','hidden']]
  end

  def public_path
    if name =~ /^[0-9]{13}$/
      _name = name.gsub(/^((\d{4})(\d\d)(\d\d)(\d\d)(\d\d).*)$/, '\2/\3/\4/\5/\6/\1')
    else
      _name = ::File.join(name[0..0], name[0..1], name[0..2], name)
    end
    "#{content.public_path}/docs/#{_name}/index.html"
  end

  def public_uri=(uri)
    @public_uri = uri
  end
  
  def public_uri
    return @public_uri if @public_uri
    return nil unless node = content.doc_node
    @public_uri = "#{node.public_uri}#{name}/"
  end
  
  def public_full_uri
    return nil unless node = content.doc_node
    "#{node.public_full_uri}#{name}/"
  end
  
  def mobile_page?
    agent_state == 'mobile'
  end
  
  def agent_filter(agent)
    self.and do |c|
      c.or :agent_state, 'IS', nil
      if agent #TODO/mobile
        c.or :agent_state, 'mobile'
      else
        c.or :agent_state, 'pc'
      end
    end
    self
  end
  
  def visible_in_notice
    self.and 'notice_state' , 'visible'
    self
  end

  def visible_in_recent
    self.and 'language_id', 1
    self.and 'recent_state' , 'visible'
    self
  end

  def visible_in_list
    #self.and 'language_id', 1
    self
  end

  def tag_is(tag)
    if tag.to_s.blank?
      self.and 0, 1
    else
      qw = self.connection.quote_string(tag).gsub(/([_%])/, '\\\\\1')
      self.and "sql", "EXISTS (SELECT * FROM faq_tags WHERE faq_docs.unid = faq_tags.unid AND word LIKE '#{qw}%') "
    end
    self
  end
  
  def group_is(group)
    conditions = []
    
    if group.category.size > 0
      doc = self.class.new
      doc.category_is(group.category_items)
      conditions << doc.condition
    end
    
    condition = Condition.new
    if group.condition == 'and'
      conditions.each {|c| condition.and(c) if c.where }
    else
      conditions.each {|c| condition.or(c) if c.where }
    end
    
    self.and condition if condition.where
    self
  end
  
  def modify_attributes
    self.agent_state = nil if agent_state == ''
    return true
  end
  
  def check_digit
    return true if name.to_s != ''
    date = Date.strptime(Core.now, '%Y-%m-%d').strftime('%Y%m%d')
    date = created_at.strftime('%Y%m%d') if created_at
    seq  = Util::Sequencer.next_id('faq_docs', :version => date)
    name = date + format('%04d', seq)
    self.name = Util::String::CheckDigit.check(name)
    return true
  end
  
  def bread_crumbs(doc_node)
    crumbs = []
    
    if content = Faq::Content::Doc.find_by_id(content_id)
      node  = content.category_node
      items = category_items
      if node && items.size > 0
        c = node.bread_crumbs.crumbs[0]
        c << items.collect{|i| [i.title, "#{node.public_uri}#{i.name}/"]}
        crumbs << c
      end
    end
    
    if crumbs.size == 0
      doc_node.routes.each do |r|
        c = []
        r.each {|i| c << [i.title, i.public_uri] }
        crumbs << c
      end
    end
    Cms::Lib::BreadCrumbs.new(crumbs)
  end

  def search(params)
    params.each do |n, v|
      next if v.to_s == ''

      case n
      when 's_id'
        self.and "#{Faq::Doc.table_name}.id", v
      when 's_category_id'
        return self.and(0, 1) unless cate = Faq::Category.find_by_id(v)
        self.category_is(cate)
      when 's_title'
        self.and_keywords v, :title
      when 's_keyword'
        self.and_keywords v, :title, :body, :question
      when 's_affiliation_name'
        self.join :creator
        self.join "INNER JOIN #{Sys::Group.table_name} ON #{Sys::Group.table_name}.id = #{Sys::Creator.table_name}.group_id"
        self.and "#{Sys::Group.table_name}.name", "LIKE", "%#{v}%"
      end
    end if params.size != 0

    return self
  end

  def publish(content, options = {})
    @save_mode = :publish
    self.state = 'public'
    self.published_at ||= Core.now
    return false unless save(:validate => false)
    
    if rep = replaced_page
      rep.destroy
    end
    
    publish_page(content, :path => public_path, :uri => public_uri)
    publish_files
    return true
  end
  
  def close
    @save_mode = :close
    self.state = 'closed' if self.state == 'public'
    #self.published_at = nil
    return false unless save(:validate => false)
    close_files
    return true
  end
  
  def close_page(options = {})
    return true if replace_page?
    super
  end
  
  def close_files
    return true if replace_page?
    super
  end
  
  def rebuild(content, options = {})
    return false unless public?
    @save_mode = :publish
    
    publish_page(content, :path => public_path, :uri => public_uri)
    publish_files if options[:file]
    return true
  end
  
  def duplicate(rel_type = nil)
    item = self.class.new(self.attributes)
    item.id            = nil
    item.unid          = nil
    item.created_at    = nil
    item.updated_at    = nil
    item.recognized_at = nil
    item.published_at  = nil
    item.state         = 'draft'
    
    if rel_type == nil
      item.name          = nil
      item.title         = item.title.gsub(/^(【複製】)*/, "【複製】")
    end
    
    item.in_recognizer_ids  = recognition.recognizer_ids if recognition
    item.in_editable_groups = editable_group.group_ids.split(' ') if editable_group
    item.in_tags            = tags.collect{|c| c.word} if tags.size > 0
    
    if inquiry != nil && inquiry.group_id == Core.user.group_id
      item.in_inquiry = inquiry.attributes
    else
      item.in_inquiry = {:group_id => Core.user.group_id}
    end
    
    return false unless item.save(:validate => false)
    
    files.each do |f|
      file = Sys::File.new(f.attributes)
      file.file        = Sys::Lib::File::NoUploadedFile.new(f.upload_path, :mime_type => file.mime_type)
      file.unid        = nil
      file.parent_unid = item.unid
      file.save
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
  
  def inquiry_email_setting
    v = content.setting_value(:inquiry_email_display)
    v.blank? ? super : v
  end
  
  # group chenge
  def information
    return "[記事]\n#{id} #{title}"
  end
end