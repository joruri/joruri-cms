# encoding: utf-8
class Article::Area < ActiveRecord::Base
  include Sys::Model::Base
  include Cms::Model::Base::Page
  include Cms::Model::Base::Page::Publisher
  include Cms::Model::Base::Page::TalkTask
  include Sys::Model::Tree
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::Creator
  include Cms::Model::Rel::Concept
  include Cms::Model::Auth::Content

  include StateText

  belongs_to :parent, foreign_key: :parent_id, class_name: to_s
  belongs_to :content, foreign_key: :content_id, class_name: 'Cms::Content'
  belongs_to :layout, foreign_key: :layout_id, class_name: 'Cms::Layout'

  has_many   :children, -> { order(:name) }, foreign_key: :parent_id, class_name: to_s, dependent: :destroy

  validates :state, :title, presence: true
  validates :name, presence: true, uniqueness: { scope: [:content_id] }

  validate :check_level_no

  scope :content_is, ->(content) {
    where(content_id: content.id)
  }

  def self.root_items(conditions = {})
    conditions = conditions.merge(parent_id: 0, level_no: 1)
    where(conditions).order(:sort_no)
  end

  def public_path
    "#{content.public_path}/areas/#{name}/index.html"
  end

  def node_label(_options = {})
    labels = []
    parents_tree.each { |c| labels << c.title }
    labels.join('/')
  end

  def public_children
    self.class.published
        .where(content_id: content_id)
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
        c << [p.title, "#{uri}#{p.name}/"]
      end

      crumbs << c
    end
    Cms::Lib::BreadCrumbs.new(crumbs)
  end

  def check_level_no
    errors.add :base, '5階層目以降は作成できません。' if level_no >= 5
  end
end
