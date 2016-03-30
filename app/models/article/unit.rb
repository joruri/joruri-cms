# encoding: utf-8
class Article::Unit < Sys::Group
  include Cms::Model::Base::Page
  include Cms::Model::Base::Page::Publisher
  include Cms::Model::Base::Page::TalkTask

  belongs_to :parent, foreign_key: 'parent_id', class_name: to_s

  has_many :children, -> { order(:sort_no) }, foreign_key: :parent_id, class_name: to_s, dependent: :destroy

  scope :published, -> {
    where(web_state: 'public')
  }

  scope :find_departments, ->(conditions = {}) {
    conditions = conditions.merge(level_no: 2)
    where(conditions).order(:sort_no)
  }

  scope :find_sections, ->(conditions = {}) {
    conditions = conditions.merge(level_no: 3)
    where(conditions).order(:sort_no)
  }

  scope :root_item, -> {
    where(parent_id: 0).order(:sort_no).first
  }

  def public_path(content)
    "#{content.public_path}/units/#{name}/index.html"
  end

  def name
    read_attribute(:name_en)
  end

  def title
    read_attribute(:name)
  end

  def node_label(_options = {})
    labels = []
    parents_tree.each { |c| labels << c.title if c.level_no != 1 }
    labels.join('/')
  end

  def public_children
    self.class.published
        .where(parent_id: id)
        .order(:sort_no)
  end

  def bread_crumbs(node)
    crumbs = []
    node.routes.each do |r|
      c = []
      r.each { |i| c << [i.title, i.public_uri] }

      uri = c.last[1] || '/'
      parents_tree.each do |p|
        c << [p.title, "#{uri}#{p.name}/"] if p.level_no != 1
      end

      crumbs << c
    end
    Cms::Lib::BreadCrumbs.new(crumbs)
  end

  def editable?
    Core.user.has_auth?(:designer)
  end
end
