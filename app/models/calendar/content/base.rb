# encoding: utf-8
class Calendar::Content::Base < Cms::Content
  has_many :events, foreign_key: :content_id,
                    class_name: 'Calendar::Event',
                    dependent: :destroy

  def event_node
    return @event_node if @event_node
    @doc_node = Cms::Node
                .published
                .where(content_id: id)
                .where(model: 'Calendar::Event')
                .order(:id)
                .first
  end
end
