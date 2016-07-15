# encoding: utf-8
class Bbs::Content::Base < Cms::Content
  has_many :items, foreign_key: :content_id,
           class_name: 'Bbs::Item', dependent: :destroy

  def thread_node
    return @thread_node if @thread_node
    @thread_node = Cms::Node
                   .published
                   .where(content_id: id)
                   .where(model: 'Bbs::Thread')
                   .order(:id)
                   .first
  end
end
