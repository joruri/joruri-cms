# encoding: utf-8
class Portal::Piece::FeedEntry < Cms::Piece
  def category
    id = setting_value(:category)
    id ? Portal::Category.find_by(id: id) : nil
  end
end
