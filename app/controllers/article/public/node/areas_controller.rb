# encoding: utf-8
class Article::Public::Node::AreasController < Cms::Controller::Public::Base
  include Article::Controller::Feed
  helper Article::DocHelper

  def pre_dispatch
    @node = Page.current_node
    return http_error(404) unless @content = @node.content

    @limit = 50

    if params[:name]
      @item = Article::Area
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
    @items = Article::Area.root_items(content_id: @content.id, state: 'public')
  end

  def show
    @page  = params[:page]

    return show_feed if params[:file] == 'feed'
    return http_error(404) unless params[:file] =~ /^(index|more)$/
    @more  = params[:file] == 'more'
    @page  = 1 if !@more && !request.mobile?
    @limit = @node.setting_value(:list_count, 10) unless @more

    @docs = Article::Doc.published
    @docs = if request.mobile?
              @docs.visible_in_list
            else
              @docs.visible_in_recent
            end
    @docs = @docs.agent_filter(request.mobile)
                 .area_is(@item)
                 .order(published_at: :desc)
                 .paginate(page: @page, per_page: @limit)
    return true if render_feed(@docs)
    return http_error(404) if @more == true && @docs.current_page > @docs.total_pages

    if @item.level_no == 1
      show_group
      return render(action: :show_group)
    elsif @item.level_no > 1
      show_detail
      return render(action: :show_detail)
    end
    http_error(404)
  end

  def show_feed # portal
    @feed = true
    @items = []
    render(action: :show_group)
  end

  def show_group
    @items = @item.public_children

    @item_docs = proc do |city|
      @docs = Article::Doc
              .published
              .visible_in_list
              .agent_filter(request.mobile)
              .area_is(city)
              .order(published_at: :desc)
              .paginate(page: @page, per_page: @limit)
    end
  end

  def show_detail
    @items = Article::Attribute
             .published
             .where(content_id: @content.id)
             .order(:sort_no)

    @item_docs = proc do |attr|
      @docs = Article::Doc.published
                          .visible_in_list
                          .agent_filter(request.mobile)
                          .area_is(@item)
                          .attribute_is(attr)
                          .order(published_at: :desc)
                          .paginate(page: @page, per_page: @limit)
    end
  end

  def show_attr
    @page = params[:page]

    @attr = Article::Attribute
            .published
            .where(content_id: @content.id)
            .where(name: params[:attr])
            .order(:sort_no)
            .first
    return http_error(404) unless @attr

    @docs = Article::Doc
            .published
            .visible_in_list
            .agent_filter(request.mobile)
            .area_is(@item)
            .attribute_is(@attr)
            .order(published_at: :desc)
            .paginate(page: @page, per_page: @limit)
    return http_error(404) if @docs.current_page > @docs.total_pages
  end
end
