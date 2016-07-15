# encoding: utf-8
class Article::Public::Node::UnitsController < Cms::Controller::Public::Base
  include Article::Controller::Feed
  helper Article::DocHelper

  def pre_dispatch
    @node = Page.current_node
    return http_error(404) unless @content = @node.content

    @limit = 50

    if params[:name]
      @item = Article::Unit
              .published
              .where(name_en: params[:name])
              .first
      return http_error(404) unless @item
      Page.current_item = @item
      Page.title        = @item.title
    end
  end

  def index
    @items = Article::Unit.root_item.public_children
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
            .agent_filter(request.mobile)
            .where(content_id: @content.id)
    @docs = if request.mobile?
              @docs.visible_in_list
            else
              @docs.visible_in_recent
            end
    @docs = @docs.unit_is(@item)
                 .paginate(page: @page, per_page: @limit)
                 .order(published_at: :desc)
    return true if render_feed(@docs)
    return http_error(404) if @more == true && @docs.current_page > @docs.total_pages

    if @item.level_no == 2
      show_department
      return render action: :show_department
    elsif @item.level_no > 2
      show_section
      return render action: :show_section
    end
    http_error(404)
  end

  def show_feed # portal
    @feed = true
    @items = []
    render(action: :show_department)
  end

  def show_department
    @items = Article::Attribute
             .published
             .where(content_id: @content.id)
             .order(:sort_no)

    @item_docs = proc do |attr|
      @docs = Article::Doc
              .published
              .agent_filter(request.mobile)
              .where(content_id: @content.id)
              .visible_in_list
              .unit_is(@item)
              .attribute_is(attr)
              .paginate(page: @page, per_page: @limit)
              .order(published_at: :desc)
    end
  end

  def show_section
    @items = Article::Attribute
             .published
             .where(content_id: @content.id)
             .order(:sort_no)

    @item_docs = proc do |attr|
      @docs = Article::Doc
              .published
              .agent_filter(request.mobile)
              .where(content_id: @content.id)
              .visible_in_list
              .unit_is(@item)
              .attribute_is(attr)
              .paginate(page: @page, per_page: @limit)
              .order(published_at: :desc)
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
            .agent_filter(request.mobile)
            .where(content_id: @content.id)
            .visible_in_list
            .unit_is(@item)
            .attribute_is(@attr)
            .paginate(page: @page, per_page: @limit)
            .order(published_at: :desc)
    return http_error(404) if @docs.current_page > @docs.total_pages
  end
end
