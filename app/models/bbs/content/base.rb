# encoding: utf-8
class Bbs::Content::Base < Cms::Content
  
  has_many :items, :foreign_key => :content_id, :class_name => 'Bbs::Item',
    :dependent => :destroy
  
  def thread_node
    return @thread_node if @thread_node
    item = Cms::Node.new.public
    item.and :content_id, id
    item.and :model, 'Bbs::Thread'
    @thread_node = item.find(:first, :order => :id)
  end
end