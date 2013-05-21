# encoding: utf-8
class Enquete::Content::Base < Cms::Content
  has_many :forms, :foreign_key => :content_id, :class_name => 'Enquete::Form',
    :dependent => :destroy
end