# encoding: utf-8
class Calendar::Content::Base < Cms::Content
  
  has_many :events, :foreign_key => :content_id, :class_name => 'Calendar::Event',
    :dependent => :destroy
  
  def event_node
    return @event_node if @event_node
    item = Cms::Node.new.public
    item.and :content_id, id
    item.and :model, 'Calendar::Event'
    @doc_node = item.find(:first, :order => :id)
  end
end