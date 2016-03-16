# encoding: utf-8
class Article::Doc < ActiveRecord::Base
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
  include Article::Model::Rel::Doc::Tag
  include Article::Model::Rel::Doc::Rel
  include Article::Model::Rel::Doc::Unit
  include Article::Model::Rel::Doc::Category
  include Article::Model::Rel::Doc::Attribute
  include Article::Model::Rel::Doc::Area
  include Cms::Model::Auth::Concept
  include Sys::Model::Auth::EditableGroup

  belongs_to :content,         :foreign_key => :content_id,     :class_name => 'Article::Content::Doc'
  belongs_to :status,          :foreign_key => :state,          :class_name => 'Sys::Base::Status'
  belongs_to :notice_status,   :foreign_key => :notice_state,   :class_name => 'Sys::Base::Status'
  belongs_to :recent_status,   :foreign_key => :recent_state,   :class_name => 'Sys::Base::Status'
  belongs_to :list_status,     :foreign_key => :list_state,     :class_name => 'Sys::Base::Status'
  belongs_to :event_status,    :foreign_key => :event_state,    :class_name => 'Sys::Base::Status'
  belongs_to :sns_link_status, :foreign_key => :sns_link_state, :class_name => 'Sys::Base::Status'
  belongs_to :language,        :foreign_key => :language_id,    :class_name => 'Sys::Language'

  attr_accessor :concept_id, :layout_id
  attr_accessor :link_checker

  before_validation :set_inquiry_email_presence

  validates_presence_of :title
  validates_uniqueness_of :name, :scope => :content_id,
    :if => %Q(!replace_page?)

  validates_presence_of :state, :recent_state, :list_state, :language_id,
    :if => %Q(state == "recognize")
  validates_length_of :title,  :maximum => 200,
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
  validate :validate_links,
    :if => %Q(link_checker)
  validate :validates_event_date,
    :if => %Q(!event_date.blank? && !event_close_date.blank?)

  before_save :check_digit
  before_save :modify_attributes

  def concept
    concept_id ? Cms::Concept.find_by_id(concept_id) : nil
  end

  def layout
    layout_id ? Cms::Layout.find_by_id(layout_id) : nil
  end

  def validates_event_date
    if event_date >= event_close_date
      errors.add :event_close_date, :greater_than, :count => locale(:event_date)
      return false
    end
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

    if !body.blank?
      words.each {|src, dst| self.body = body.gsub(src, dst) }
    end
    if !mobile_body.blank?
      words.each {|src, dst| self.mobile_body = mobile_body.gsub(src, dst) }
    end
  end

  def validate_platform_dependent_characters
    [:title, :body, :mobile_body].each do |attr|
      if chars = Util::String.search_platform_dependent_characters(send(attr))
        errors.add attr, :platform_dependent_characters, :chars => chars
      end
    end
  end

  def validate_links
    unless @link_checker.check_link(body)
      errors.add :base, "リンクチェックの結果を確認してください。"
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

  def list_states
    [['表示','visible'],['非表示','hidden']]
  end

  def event_states
    [['表示','visible'],['非表示','hidden']]
  end

  def sns_link_states
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

  def summary_body
    require 'hpricot'
    Hpricot.uxs self.body.to_s.gsub(/<("[^"]*"|'[^']*'|[^'">])*>/, "").gsub(/(\r\n|\r|\n)+/, ' ')
  end

  def thumbnail_file
    return @_thumbnail_file if @_thumbnail_file
    if body =~ /<img [^>]*src="(\.\/)?files\/[^"]+"/i
      body.scan(/<img [^>]*src="(?:\.\/)?files\/(?:thumb\/)?([^"]+)"/i) do |m|
        files.each do |file|
          return @_thumbnail_file = file if file.name == m[0] && file.has_thumbnail?
        end
      end
    end
    nil
  end

  def thumbnail_uri
    if file = thumbnail_file
      return "#{public_uri}files/thumb/#{file.name}"
    end
    return nil
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
    self.and 'list_state' , 'visible'
    self
  end

  def event_date_in(sdate, edate)
    self.and :language_id, 1
    self.and :event_state, 'visible'
    self.and :event_date, 'IS NOT', nil

    self.and Condition.new do |c|
      c.or Condition.new do |c2|
        c2.and :event_date, "<", edate.to_s
        c2.and :event_close_date, ">=", sdate.to_s
      end
      c.or Condition.new do |c2|
        c2.and :event_close_date, "IS", nil
        c2.and :event_date, ">=", sdate.to_s
        c2.and :event_date, "<", edate.to_s
      end
    end
    self
  end

  def event_date_is(options = {})
    self.and :language_id, 1
    self.and :event_state, 'visible'
    self.and :event_date, 'IS NOT', nil

    if options[:year] && options[:month]
      sdate = Date.new(options[:year], options[:month], 1)
      edate = sdate >> 1
      self.and :event_date, '>=', sdate
      self.and :event_date, '<' , edate
    elsif options[:year]
      sdate = Date.new(options[:year], 1, 1)
      edate = sdate >> 12
      self.and :event_date, '>=', sdate
      self.and :event_date, '<' , edate
    end

    self
  end

  def tag_is(tag)
    if tag.to_s.blank?
      self.and 0, 1
    else
      qw = self.connection.quote_string(tag).gsub(/([_%])/, '\\\\\1')
      self.and "sql", "EXISTS (SELECT * FROM article_tags WHERE article_docs.unid = article_tags.unid AND word LIKE '#{qw}%') "
    end
    self
  end

  def group_is(group)
    conditions = []

    if group.unit.size > 0
      join :creator
      doc = self.class.new
      doc.unit_is(group.unit_items)
      conditions << doc.condition
    end
    if group.category.size > 0
      doc = self.class.new
      doc.category_is(group.category_items)
      conditions << doc.condition
    end
    if group.attribute.size > 0
      doc = self.class.new
      doc.attribute_is(group.attribute_items)
      conditions << doc.condition
    end
    if group.area.size > 0
      doc = self.class.new
      doc.area_is(group.area_items)
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

  def new_mark
    term = content.setting_value(:new_term).to_f * 60
    return false if term <= 0

    published_at = term.minutes.since self.published_at
    return ( published_at.to_i >= Time.now.to_i )
  end


  def check_digit
    return true if name.to_s != ''
    date = Date.strptime(Core.now, '%Y-%m-%d').strftime('%Y%m%d')
    date = created_at.strftime('%Y%m%d') if created_at
    seq  = Util::Sequencer.next_id('article_docs', :version => date)
    name = date + format('%04d', seq)
    self.name = Util::String::CheckDigit.check(name)
    return true
  end

  def bread_crumbs(doc_node)
    crumbs = []

    if content = Article::Content::Doc.find_by_id(content_id)
      node = content.unit_node
      item = unit
      if node && item && item.web_state == 'public'
        c = node.bread_crumbs.crumbs[0]
        c << [unit.title, "#{node.public_uri}#{unit.name}/"]
        crumbs << c
      end

      node  = content.category_node
      items = category_items(:state => "public")
      if node && items.size > 0
        c = node.bread_crumbs.crumbs[0]
        c << items.collect{|i| [i.title, "#{node.public_uri}#{i.name}/"]}
        crumbs << c
      end

      node  = content.attribute_node
      items = attribute_items(:state => "public")
      if node && items.size > 0
        c = node.bread_crumbs.crumbs[0]
        c << items.collect{|i| [i.title, "#{node.public_uri}#{i.name}/"]}
        crumbs << c
      end

      node  = content.area_node
      items = area_items(:state => "public")
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
        self.and "#{Article::Doc.table_name}.id", v
      when 's_section_id'
        return self.and(0, 1) unless sec = Article::Unit.find_by_id(v)
        return self.department_is(sec) if sec.level_no == 2
        self.unit_is(sec)
      when 's_category_id'
        return self.and(0, 1) unless cate = Article::Category.find_by_id(v)
        #return self.category_in(cate.public_children) if cate.level_no == 1
        self.category_is(cate)
      when 's_attribute_id'
        self.attribute_is(v)
      when 's_area_id'
        return self.and(0, 1) unless area = Article::Area.find_by_id(v)
        return self.area_is(area.public_children) if area.level_no == 1
        self.area_is(area)
      when 's_title'
        self.and_keywords v, :title
      when 's_keyword'
        self.and_keywords v, :title, :body
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

    if maps.size > 0
      _maps = {}
      maps.each do |m|
        _maps[m.name] = m.in_attributes.symbolize_keys
        _maps[m.name][:markers] = {}
        m.markers.each_with_index{|mm, key| _maps[m.name][:markers][key] = mm.attributes.symbolize_keys}
      end
      item.in_maps = _maps
    end

    return false unless item.save(:validate => false)

    files.each do |f|
      file = Sys::File.new(f.attributes)
      file.use_resize(false)
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

  def default_map_position
    v = content.setting_value(:default_map_position)
    v.blank? ? super : v
  end

  def inquiry_email_setting
    v = content.setting_value(:inquiry_email_display)
    v.blank? ? super : v
  end

  def set_inquiry_email_presence
    self.unset_inquiry_email_presence if self.unset_inquiry_email_presence?
  end

  def unset_inquiry_email_presence?
    inquiry_email_setting != 'visible' ? true : false
  end

  # group chenge
  def information
    return "[記事]\n#{id} #{title}"
  end
end
