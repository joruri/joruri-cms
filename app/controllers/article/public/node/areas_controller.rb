# encoding: utf-8
class Article::Public::Node::AreasController < Cms::Controller::Public::Base
  include Article::Controller::Feed
  helper Article::DocHelper
  
  def pre_dispatch
    @node = Page.current_node
    return http_error(404) unless @content = @node.content
    
    @limit = 50
    
    if params[:name]
      item = Article::Area.new.public
      item.and :content_id, @content.id
      item.and :name, params[:name]
      return http_error(404) unless @item = item.find(:first)
      Page.current_item = @item
      Page.title        = @item.title
    end
  end
  
  def index
    @items = Article::Area.root_items(:content_id => @content.id, :state => 'public')
  end

  def show
    @page  = params[:page]
    
    return show_feed if params[:file] == "feed"
    return http_error(404) unless params[:file] =~ /^(index|more)$/
    @more  = params[:file] == 'more'
    @page  = 1  if !@more && !request.mobile?
    @limit = @node.setting_value(:list_count, 10) if !@more
    
    doc = Article::Doc.new.public
    request.mobile? ? doc.visible_in_list : doc.visible_in_recent
    doc.agent_filter(request.mobile)
    doc.area_is @item
    doc.page @page, @limit
    @docs = doc.find(:all, :order => 'published_at DESC')
    return true if render_feed(@docs)
    return http_error(404) if @more == true && @docs.current_page > @docs.total_pages

    if @item.level_no == 1
      show_group
      return render(:action => :show_group)
    elsif @item.level_no > 1
      show_detail
      return render(:action => :show_detail)
    end
    return http_error(404)
  end

  def show_feed #portal
    @feed = true
    @items = []
    return render(:action => :show_group)
  end
  
  def show_group
    @items = @item.public_children

    @item_docs = Proc.new do |city|
      doc = Article::Doc.new.public
      doc.visible_in_list
      doc.agent_filter(request.mobile)
      doc.area_is city
      doc.page @page, @limit
      @docs = doc.find(:all, :order => 'published_at DESC')
    end
  end

  def show_detail
    cond = { :content_id => @content.id }
    @items = Article::Attribute.new.public.find(:all, :conditions => cond, :order => :sort_no)

    @item_docs = Proc.new do |attr|
      doc = Article::Doc.new.public
      doc.visible_in_list
      doc.agent_filter(request.mobile)
      doc.area_is @item
      doc.attribute_is attr
      doc.page @page, @limit
      @docs = doc.find(:all, :order => 'published_at DESC')
    end
  end
  
  def show_attr
    @page  = params[:page]
    
    attr = Article::Attribute.new.public
    attr.and :name, params[:attr]
    return http_error(404) unless @attr = attr.find(:first, :order => :sort_no)
    
    doc = Article::Doc.new.public
    doc.visible_in_list
    doc.agent_filter(request.mobile)
    doc.area_is @item
    doc.attribute_is @attr
    doc.page @page, @limit
    @docs = doc.find(:all, :order => 'published_at DESC')
    return http_error(404) if @docs.current_page > @docs.total_pages
  end
end
