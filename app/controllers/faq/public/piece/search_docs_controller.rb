# encoding: utf-8
class Faq::Public::Piece::SearchDocsController < Sys::Controller::Public::Base
  def index
    @piece   = Page.current_piece
    @content = Faq::Content::Doc.find(@piece.content_id)
    @node    = @content.search_node

    return render(text: '') unless @node
    @node_uri = @node.public_uri

    @categories1    = []
    @categories2    = [["大分類を選択してください", '']]
    @categories3    = [["中分類を選択してください", '']]
    @s_category1_id = params[:s_category1_id]
    @s_category2_id = params[:s_category2_id]
    @s_category3_id = params[:s_category3_id]
    @s_keyword      = params[:s_keyword]

    item = Faq::Category
           .published
           .select(:level_no)
           .order(level_no: :desc)
           .first
    @depth = item ? item.level_no : 0

    items = Faq::Category
           .published
           .where(content_id: @content.id)
           .where(level_no: 1)
           .order(:sort_no)
    @categories1 = [['', '']] + items.collect { |c| [c.title, c.id] }

    unless @s_category1_id.blank?
      items = Faq::Category
              .published
              .where(content_id: @content.id)
              .where(parent_id: @s_category1_id)
              .where(level_no: 2)
              .order(:sort_no)
      @categories2 = [['', '']] + items.collect { |c| [c.title, c.id] }
    end

    unless @s_category2_id.blank?
      items = Faq::Category
              .published
              .where(content_id: @content.id)
              .where(parent_id: @s_category2_id)
              .where(level_no: 3)
              .order(:sort_no)
      @categories3 = [['', '']] + items.collect { |c| [c.title, c.id] }
    end
  end
end
