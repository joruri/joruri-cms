# encoding: utf-8
class Faq::Public::Node::CategoriesController < Cms::Controller::Public::Base
  include Faq::Controller::Feed

  def pre_dispatch
    return http_error(404) unless @content = Page.current_node.content
    @docs_uri = @content.public_uri('Faq::Doc')
    
    @limit = 50
    
    if params[:name]
      item = Faq::Category.new.public
      item.and :content_id, @content.id
      item.and :name, params[:name]
      return http_error(404) unless @item = item.find(:first)
      Page.current_item = @item
      Page.title        = @item.title
    end
  end
  
  def index
    @items = Faq::Category.root_items(:content_id => @content.id, :state => 'public')
  end

  def show
    @page  = params[:page]
    
    return show_feed if params[:file] == "feed"
    return http_error(404) unless params[:file] =~ /^(index|more)$/
    @more  = (params[:file] == 'more')
    @page  = 1  if !@more && !request.mobile?
    @limit = 10 if !@more
    
    doc = Faq::Doc.new.public
    request.mobile? ? doc.visible_in_list : doc.visible_in_recent
    doc.agent_filter(request.mobile)
    doc.category_is @item
    doc.page @page, @limit
    @docs = doc.find(:all, :order => 'published_at DESC')
    return true if render_feed(@docs)
    
    return http_error(404) if @more == true && @docs.current_page > @docs.total_pages
    
    show_group
    return render :action => :show_group
  end
  
  def show_group
    @items = @item.public_children

    @item_docs = Proc.new do |cate|
      doc = Faq::Doc.new.public
      doc.agent_filter(request.mobile)
      doc.visible_in_list
      doc.category_is cate
      doc.page @page, @limit
      @docs = doc.find(:all, :order => 'published_at DESC')
    end
  end
end
