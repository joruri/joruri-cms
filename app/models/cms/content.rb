# encoding: utf-8
class Cms::Content < ActiveRecord::Base
  include Sys::Model::Base
  include Cms::Model::Base::Content
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::Creator
  include Cms::Model::Rel::Site
  include Cms::Model::Rel::Concept
  include Cms::Model::Auth::Concept

  has_many :settings, -> { order(:sort_no) }, foreign_key: :content_id, class_name: 'Cms::ContentSetting', dependent: :destroy
  has_many :pieces, foreign_key: :content_id, class_name: 'Cms::Piece',
                    dependent: :destroy
  has_many :nodes, foreign_key: :content_id, class_name: 'Cms::Node',
                   dependent: :destroy

  validates_presence_of :concept_id, :state, :model, :name

  after_save :save_settings

  scope :search, -> (params) {
    rel = all

    data_texts = arel_table

    params.each do |n, v|
      next if v.to_s == ''

      case n
      when 's_name'
        rel = rel.where(data_texts[:name].matches("%#{v}%"))
      end
    end if params.size != 0

    rel
  }

  def in_settings
    unless @in_settings
      values = {}
      settings.each do |st|
        if st.sort_no
          values[st.name] ||= {}
          values[st.name][st.sort_no] = value
        else
          values[st.name] = st.value
        end
      end
      @in_settings = values
    end
    @in_settings
  end

  attr_writer :in_settings

  def locale(name)
    model = self.class.to_s.underscore
    label = ''
    if model != 'cms/content'
      label = I18n.t name, scope: [:activerecord, :attributes, model]
      return label if label !~ /^translation missing:/
    end
    label = I18n.t name, scope: [:activerecord, :attributes, 'cms/content']
    label =~ /^translation missing:/ ? name.to_s.humanize : label
  end

  def states
    [%w(公開 public)]
  end

  def node_is(node)
    node = Cms::Node.find_by(id: node) if node.class != Cms::Node
    self.and :id, node.content_id if node
  end

  def new_setting(name = nil)
    Cms::ContentSetting.new(content_id: id, name: name.to_s)
  end

  def setting_value(name, default_value = nil)
    st = settings.find_by(name: name.to_s)
    return default_value unless st
    st.value.blank? ? default_value : st.value
  end

  def rewrite_configs
    []
  end

  def self.rewrite_regex(options = {})
    conf = []

    Cms::Content.where(site_id: options[:site_id]).order(:id).each do |item|
      name = item.model.to_s.gsub(/^(.*?::)/, '\\1Content::')
      begin
        eval(name)
        model = eval(name)
      rescue
        model = nil
      end
      next unless model
      content = model.find_by_id(item.id)
      next unless content
      content.rewrite_configs.each do |line|
        val = line.split(/ /)
        next if val[0] != 'RewriteRule'
        conf << [val[1], val[2]]
      end
    end

    conf
  end

  protected

  def save_settings
    in_settings.each do |name, value|
      st = settings.find_by(name: name) || new_setting(name)
      st.value = value
      st.save if st.changed?
    end
    true
  end
end
