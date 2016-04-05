# encoding: utf-8
class Portal::Category < ActiveRecord::Base
  include Sys::Model::Base
  include Cms::Model::Base::Page
  include Cms::Model::Base::Page::Publisher
  include Cms::Model::Base::Page::TalkTask
  include Sys::Model::Tree
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::Creator
  include Cms::Model::Auth::Content

  include StateText

  belongs_to :parent,  foreign_key: :parent_id,  class_name: to_s
  belongs_to :content, foreign_key: :content_id, class_name: 'Cms::Content'
  belongs_to :layout, foreign_key: :layout_id, class_name: 'Cms::Layout'

  has_many   :children, foreign_key: :parent_id, class_name: to_s,
                        order: :sort_no, dependent: :destroy

  validates :state, :parent_id, :name, :title, presence: true

  def self.root_items(conditions = {})
    conditions = conditions.merge(parent_id: 0, level_no: 1)
    where(conditions).order(:sort_no)
  end

  def public_path
    "#{content.public_path}/categories/#{name}/index.html"
  end

  def public_children
    self.class.published
              .where(content_id: content_id)
              .where(parent_id: id)
              .order(:sort_no)
  end

  def node_label(_options = {})
    labels = []
    parents_tree.each { |c| labels << c.title }
    labels.join('/')
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

  def article_groups(article_content = nil)
    result = []

    doc_cates = []
    doc_attrs = []
    doc_units = []
    doc_areas = []

    if entry_categories
      cates = entry_categories.split(/\r\n|\r|\n/)
      cates.each do |cate|
        labels = cate.split(/\//)
        case labels[0]
        when '分野'
          l = (labels.size >= 3) ? labels[2] : labels[1]
          doc_cates << l
        when '属性'
          l = (labels.size >= 3) ? labels[2] : labels[1]
          doc_attrs << l
        when '組織'
          l = (labels.size >= 3) ? labels[2] : labels[1]
          doc_units << l
        when '地域'
          l = (labels.size >= 3) ? labels[2] : labels[1]
          doc_areas << l
        end if labels.size > 0
      end
      doc_cates.uniq!
      doc_cates.each do |t|
        cate = Article::Category
               .published
               .where(content_id: article_content)
               .where(title: t)
               .first
        result << { kind: 'cate', instance: cate }
      end

      doc_attrs.uniq!
      doc_attrs.each do |t|
        attr = Article::Attribute
               .published
               .where(content_id: article_content)
               .where(title: t)
               .first
        result << { kind: 'attr', instance: attr }
      end

      doc_units.uniq!
      doc_units.each do |t|
        unit = Article::Unit
               .published
               .where(name: t)
               .first
        result << { kind: 'unit', instance: unit }
      end

      doc_areas.uniq!
      doc_areas.each do |t|
        area = Article::Area
               .published
               .where(content_id: article_content)
               .where(title: t)
               .first
        result << { kind: 'area', instance: area }
      end

    end
    result
  end
end
