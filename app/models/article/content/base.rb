# encoding: utf-8
class Article::Content::Base < Cms::Content
  has_many :dependent_docs, :foreign_key => :content_id, :class_name => 'Article::Doc',
    :dependent => :destroy
  has_many :dependent_categories, :foreign_key => :content_id, :class_name => 'Article::Category',
    :dependent => :destroy
  has_many :dependent_areas, :foreign_key => :content_id, :class_name => 'Article::Area',
    :dependent => :destroy
  has_many :dependent_attributes, :foreign_key => :content_id, :class_name => 'Article::Attribute',
    :dependent => :destroy
end