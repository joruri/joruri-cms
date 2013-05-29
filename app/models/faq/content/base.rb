# encoding: utf-8
class Faq::Content::Base < Cms::Content
  has_many :dependent_docs, :foreign_key => :content_id, :class_name => 'Faq::Doc',
    :dependent => :destroy
  has_many :dependent_categories, :foreign_key => :content_id, :class_name => 'Faq::Category',
    :dependent => :destroy
end