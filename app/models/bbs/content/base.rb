# encoding: utf-8
class Bbs::Content::Base < Cms::Content
  def thread_node
    return @thread_node if @thread_node
    item = Cms::Node.new.public
    item.and :content_id, id
    item.and :model, 'Bbs::Thread'
    @thread_node = item.find(:first, :order => :id)
  end
end