# encoding: utf-8
class Portal::Content::Base < Cms::Content
  has_many :feeds, :foreign_key => :content_id, :class_name => 'Cms::Feed',
    :dependent => :destroy
  
  def doc_content
    id = setting_value(:doc_content_id)
    return nil unless id
    Cms::Content.find_by_id(id)
  end
end