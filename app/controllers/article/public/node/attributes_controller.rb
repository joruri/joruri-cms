# encoding: utf-8
class Article::Public::Node::AttributesController < Cms::Controller::Public::Base
  include Article::Controller::Feed
  helper Article::DocHelper

  def pre_dispatch
    @node = Page.current_node
    @content = @node.content
    return http_error(404) unless @content

    @limit = 50

    if params[:name]
      @item = Article::Attribute
              .published
              .where(content_id: @content.id)
              .where(name: params[:name])
              .first
      return http_error(404) unless @item
      Page.current_item = @item
      Page.title        = @item.title
    end
  end

  def index
    @items = Article::Attribute
             .published
             .where(content_id: @content.id)
             .order(:sort_no)
  end

  def show
    @page  = params[:page]

    return show_feed if params[:file] == 'feed'
    return http_error(404) unless params[:file] =~ /^(index|more)$/
    @more  = params[:file] == 'more'
    @page  = 1 if !@more && !request.mobile?
    @limit = @node.setting_value(:list_count, 10) unless @more

    @docs = Article::Doc
            .published
            .visible_in_recent
            .agent_filter(request.mobile)
            .attribute_is(@item)
            .order(published_at: :desc)
            .paginate(page: @page, per_page: @limit)
    return true if render_feed(@docs)
    return http_error(404) if @more == true && @docs.current_page > @docs.total_pages

    @items = Article::Unit.find_departments(web_state: 'public')

    @item_docs = proc do |dep|
      @docs = Article::Doc
              .published
              .visible_in_list
              .agent_filter(request.mobile)
              .attribute_is(@item)
              .unit_is(dep)
              .order(published_at: :desc)
              .paginate(page: @page, per_page: @limit)
    end
  end

  def show_feed # portal
    @feed = true
    @items = []
    render(action: :show)
  end

  def show_attr
    @page = params[:page]

    @attr = Article::Unit
            .published
            .where(ame_en: params[:attr])
            .order(:sort_no)
            .first
    return http_error(404) unless @attr

    @docs = Article::Doc
            .published
            .visible_in_list
            .agent_filter(request.mobile)
            .attribute_is(@item)
            .unit_is(@attr)
            .order(published_at: :desc)
            .paginate(page: @page, per_page: @limit)
    return http_error(404) if @docs.current_page > @docs.total_pages
  end
end
