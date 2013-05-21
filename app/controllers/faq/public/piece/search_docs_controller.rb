# encoding: utf-8
class Faq::Public::Piece::SearchDocsController < Sys::Controller::Public::Base
  def index
    @piece   = Page.current_piece
    @content = Faq::Content::Doc.find(@piece.content_id)
    @node    = @content.search_node
    
    return render(:text => "") unless @node
    @node_uri = @node.public_uri
    
    @categories1    = []
    @categories2    = [["大分類を選択してください",""]]
    @categories3    = [["中分類を選択してください",""]]
    @s_category1_id = params[:s_category1_id]
    @s_category2_id = params[:s_category2_id]
    @s_category3_id = params[:s_category3_id]
    @s_keyword      = params[:s_keyword]
    
    item = Faq::Category.new.public
    item = item.find(:first, :select => :level_no, :order => "level_no DESC")
    @depth = item ? item.level_no : 0
    
    item = Faq::Category.new.public
    item.and :content_id, @content.id
    item.and :level_no, 1
    @categories1 = [["",""]] + item.find(:all, :order => :sort_no).collect{|c| [c.title, c.id] }
    
    if !@s_category1_id.blank?
      item = Faq::Category.new.public
      item.and :content_id, @content.id
      item.and :parent_id, @s_category1_id
      item.and :level_no, 2
      @categories2 = [["",""]] + item.find(:all, :order => :sort_no).collect{|c| [c.title, c.id] }
    end
    
    if !@s_category2_id.blank?
      item = Faq::Category.new.public
      item.and :content_id, @content.id
      item.and :parent_id, @s_category2_id
      item.and :level_no, 3
      @categories3 = [["",""]] + item.find(:all, :order => :sort_no).collect{|c| [c.title, c.id] }
    end
    
  end
end
