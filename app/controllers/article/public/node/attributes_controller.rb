# encoding: utf-8
class Article::Public::Node::AttributesController < Cms::Controller::Public::Base
  include Article::Controller::Feed
  helper Article::DocHelper

  def pre_dispatch
    @node = Page.current_node
    return http_error(404) unless @content = @node.content
    
    @limit = 50
    
    if params[:name]
      item = Article::Attribute.new.public
      item.and :content_id, @content.id
      item.and :name, params[:name]
      return http_error(404) unless @item = item.find(:first)
      Page.current_item = @item
      Page.title        = @item.title
    end
  end
  
  def index
    item = Article::Attribute.new.public
    item.and :content_id, @content.id
    @items = item.find(:all, :order => :sort_no)
  end
  
  def show
    @page  = params[:page]
    
    return show_feed if params[:file] == "feed"
    return http_error(404) unless params[:file] =~ /^(index|more)$/
    @more  = params[:file] == 'more'
    @page  = 1  if !@more && !request.mobile?
    @limit = @node.setting_value(:list_count, 10) if !@more
    
    doc = Article::Doc.new.public
    doc.visible_in_recent
    doc.agent_filter(request.mobile)
    doc.attribute_is @item
    doc.page @page, @limit
    @docs = doc.find(:all, :order => 'published_at DESC')
    return true if render_feed(@docs)
    return http_error(404) if @more == true && @docs.current_page > @docs.total_pages
    
    @items = Article::Unit.find_departments(:web_state => 'public')

    @item_docs = Proc.new do |dep|
      doc = Article::Doc.new.public
      doc.visible_in_list
      doc.agent_filter(request.mobile)
      doc.attribute_is @item
      doc.unit_is dep
      doc.page @page, @limit
      @docs = doc.find(:all, :order => 'published_at DESC')
    end
  end
  
  def show_feed #portal
    @feed = true
    @items = []
    return render(:action => :show)
  end
  
  def show_attr
    @page  = params[:page]
    
    attr = Article::Unit.new.public
    attr.and :name_en, params[:attr]
    return http_error(404) unless @attr = attr.find(:first, :order => :sort_no)
    
    doc = Article::Doc.new.public
    doc.visible_in_list
    doc.agent_filter(request.mobile)
    doc.attribute_is @item
    doc.unit_is @attr
    doc.page @page, @limit
    @docs = doc.find(:all, :order => 'published_at DESC')
    return http_error(404) if @docs.current_page > @docs.total_pages
  end
end
