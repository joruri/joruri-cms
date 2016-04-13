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

  include StateText
  include AgentStateText

  belongs_to :content, foreign_key: :content_id,
                       class_name: 'Faq::Content::Doc'

  belongs_to :language, foreign_key: :language_id,
                        class_name: 'Sys::Language'

  attr_accessor :concept_id, :layout_id

  validates :title, presence: true
  validates :name, uniqueness: { scope: :content_id },
            if: %(!replace_page?)

  validates :state, :recent_state, :language_id, :question, :body,
            presence: true, if: %(state == "recognize")
  validates :title, length: { maximum: 200 },
            if: %(state == "recognize")
  validates :question, length: { maximum: 100_000 },
            if: %(state == "recognize")
  validates :body, length: { maximum: 100_000 },
            if: %(state == "recognize")
  validates :mobile_body, length: { maximum: 10_000 },
            if: %(state == "recognize")
  validate :validate_word_dictionary,
           if: %(state == "recognize")
  validate :validate_platform_dependent_characters,
           if: %(state == "recognize")
  validate :validate_inquiry,
           if: %(state == "recognize")
  validate :validate_recognizers,
           if: %(state == "recognize")

  before_save :check_digit
  before_save :modify_attributes

  scope :agent_filter, ->(agent) {
    if agent
      where(arel_table[:agent_state].eq(nil)
                  .or(arel_table[:agent_state].eq('mobile')))
    else
      where(arel_table[:agent_state].eq(nil)
                  .or(arel_table[:agent_state].eq('pc')))
    end
  }

  scope :visible_in_recent, -> {
    where(language_id: 1, recent_state: 'visible')
  }

  scope :visible_in_list, -> {
    all
  }

  scope :tag_is, ->(tag) {
    if tag.to_s.blank?
      none
    else
      qw = connection.quote_string(tag).gsub(/([_%])/, '\\\\\1')
      tags = Faq::Tag.arel_table
      cond = Faq::Tag.where(arel_table[:unid].eq(tags[:unid])
                            .and(tags[:word].matches("#{qw}%")))
                     .project("'X'")
                     .exists
      where(cond)
    end
  }

  scope :group_is, ->(group) {
    rel = all

    if group.category.size > 0
      rel = rel.category_is(group.category_items)
    end

    rel
  }

  scope :search, -> (params){
    rel = all

    docs = arel_table

    params.each do |n, v|
      next if v.to_s == ''

      case n
      when 's_id'
        rel = rel.where(id: v)
      when 's_category_id'
        cate = Faq::Category.find_by(id: v)
        return rel.where(0, 1) unless cate
        rel = rel.category_is(cate)
      when 's_title'
        rel = rel.where(docs[:title].matches("%#{v}%"))
      when 's_keyword'
        rel = rel.where(docs[:title].matches("%#{v}%")
                        .or(docs[:body].matches("%#{v}%"))
                        .or(docs[:question].matches("%#{v}%")))
      when 's_affiliation_name'
        creators = Sys::Creator.arel_table
        groups = Sys::Group.arel_table

        rel = rel.joins(creator: [:group])
                 .where(groups[:name].matches("%#{v}%"))
      end
    end if params.size != 0

    return rel
  }

  def concept
    concept_id ? Cms::Concept.find_by(id: concept_id) : nil
  end

  def layout
    layout_id ? Cms::Layout.find_by(id: layout_id) : nil
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

    unless question.blank?
      words.each { |src, dst| self.question = question.gsub(src, dst) }
    end
    words.each { |src, dst| self.body = body.gsub(src, dst) } unless body.blank?
    unless mobile_body.blank?
      words.each { |src, dst| self.mobile_body = mobile_body.gsub(src, dst) }
    end
  end

  def validate_platform_dependent_characters
    [:title, :body, :mobile_body, :question].each do |attr|
      if chars = Util::String.search_platform_dependent_characters(send(attr))
        errors.add attr, :platform_dependent_characters, chars: chars
      end
    end
  end

  def states
    s = [%w(下書き保存 draft), %w(承認待ち recognize)]
    s << %w(公開保存 public) if Core.user.has_auth?(:manager)
    s
  end

  def agent_states
    [['全てに表示', ''], %w(PCのみ表示 pc), %w(携帯のみ表示 mobile)]
  end

  def recent_states
    [%w(表示 visible), %w(非表示 hidden)]
  end

  def public_path
    if name =~ /^[0-9]{13}$/
      _name = name.gsub(/^((\d{4})(\d\d)(\d\d)(\d\d)(\d\d).*)$/, '\2/\3/\4/\5/\6/\1')
    else
      _name = ::File.join(name[0..0], name[0..1], name[0..2], name)
    end
    "#{content.public_path}/docs/#{_name}/index.html"
  end

  attr_writer :public_uri

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

  def modify_attributes
    self.agent_state = nil if agent_state == ''
    true
  end

  def check_digit
    return true if name.to_s != ''
    date = Date.strptime(Core.now, '%Y-%m-%d').strftime('%Y%m%d')
    date = created_at.strftime('%Y%m%d') if created_at
    seq  = Util::Sequencer.next_id('faq_docs', version: date)
    name = date + format('%04d', seq)
    self.name = Util::String::CheckDigit.check(name)
    true
  end

  def bread_crumbs(doc_node)
    crumbs = []

    if content = Faq::Content::Doc.find_by(id: content_id)
      node  = content.category_node
      items = category_items
      if node && items.size > 0
        c = node.bread_crumbs.crumbs[0]
        c << items.collect { |i| [i.title, "#{node.public_uri}#{i.name}/"] }
        crumbs << c
      end
    end

    if crumbs.size == 0
      doc_node.routes.each do |r|
        c = []
        r.each { |i| c << [i.title, i.public_uri] }
        crumbs << c
      end
    end
    Cms::Lib::BreadCrumbs.new(crumbs)
  end

  def publish(content, _options = {})
    @save_mode = :publish
    self.state = 'public'
    self.published_at ||= Core.now
    return false unless save(validate: false)

    if rep = replaced_page
      rep.destroy
    end

    publish_page(content, path: public_path, uri: public_uri)
    publish_files
    true
  end

  def close
    @save_mode = :close
    self.state = 'closed' if state == 'public'
    # self.published_at = nil
    return false unless save(validate: false)
    close_files
    true
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

    publish_page(content, path: public_path, uri: public_uri)
    publish_files if options[:file]
    true
  end

  def duplicate(rel_type = nil)
    item = self.class.new(attributes)
    item.id            = nil
    item.unid          = nil
    item.created_at    = nil
    item.updated_at    = nil
    item.recognized_at = nil
    item.published_at  = nil
    item.state         = 'draft'

    if rel_type.nil?
      item.name          = nil
      item.title         = item.title.gsub(/^(【複製】)*/, "【複製】")
    end

    item.in_recognizer_ids  = recognition.recognizer_ids if recognition
    item.in_editable_groups = editable_group.group_ids.split(' ') if editable_group
    item.in_tags            = tags.collect(&:word) if tags.size > 0

    item.in_inquiry = if !inquiry.nil? && inquiry.group_id == Core.user.group_id
                        inquiry.attributes
                      else
                        { group_id: Core.user.group_id }
                      end

    return false unless item.save(validate: false)

    files.each do |f|
      file = Sys::File.new(f.attributes)
      file.file        = Sys::Lib::File::NoUploadedFile.new(f.upload_path, mime_type: file.mime_type)
      file.unid        = nil
      file.parent_unid = item.unid
      file.save
    end

    if rel_type == :replace
      rel = Sys::UnidRelation.new
      rel.unid     = item.unid
      rel.rel_unid = unid
      rel.rel_type = 'replace'
      rel.save
    end

    item
  end

  def inquiry_email_setting
    v = content.setting_value(:inquiry_email_display)
    v.blank? ? super : v
  end

  # group chenge
  def information
    "[記事]\n#{id} #{title}"
  end
end
