# encoding: utf-8
class Article::Attribute < ActiveRecord::Base
  include Sys::Model::Base
  include Cms::Model::Base::Page
  include Cms::Model::Base::Page::Publisher
  include Cms::Model::Base::Page::TalkTask
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::Creator
  include Cms::Model::Rel::Concept
  include Cms::Model::Auth::Content

  include StateText

  belongs_to :content, foreign_key: :content_id, class_name: 'Cms::Content'
  belongs_to :layout, foreign_key: :layout_id, class_name: 'Cms::Layout'

  validates :state, :title, presence: true
  validates :name, presence: true, uniqueness: { scope: [:content_id] }

  def self.root_items(conditions = {})
    conditions = conditions.merge({})
    find(:all, conditions: conditions, order: :sort_no)
  end

  def public_path
    "#{content.public_path}/attributes/#{name}/index.html"
  end

  def node_label(_options = {})
    title
  end

  def bread_crumbs(node)
    crumbs = []
    node.routes.each do |r|
      c = []
      r.each { |i| c << [i.title, i.public_uri] }

      uri = c.last[1] || '/'
      c << [title, "#{uri}#{name}/"]

      crumbs << c
    end
    Cms::Lib::BreadCrumbs.new(crumbs)
  end
end
