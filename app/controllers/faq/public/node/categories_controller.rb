# encoding: utf-8
class Faq::Public::Node::CategoriesController < Cms::Controller::Public::Base
  include Faq::Controller::Feed

  def pre_dispatch
    @node = Page.current_node
    return http_error(404) unless @content = @node.content
    @docs_uri = @content.public_uri('Faq::Doc')

    @limit = 50

    if params[:name]
      @item = Faq::Category
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
    @items = Faq::Category.root_items(content_id: @content.id, state: 'public')
  end

  def show
    @page  = params[:page]

    return show_feed if params[:file] == 'feed'
    return http_error(404) unless params[:file] =~ /^(index|more)$/
    @more  = (params[:file] == 'more')
    @page  = 1  if !@more && !request.mobile?
    @limit = @node.setting_value(:list_count, 10) unless @more

    @docs = Faq::Doc.published

    @docs = if request.mobile?
              @docs.visible_in_list
            else
              @docs.visible_in_recent
            end

    @docs = @docs.agent_filter(request.mobile)
                 .category_is(@item)
                 .order(published_at: :desc)
                 .paginate(page: @page, per_page: @limit)

    return true if render_feed(@docs)

    if @more == true && @docs.current_page > @docs.total_pages
      return http_error(404)
    end

    show_group
    render action: :show_group
  end

  def show_group
    @items = @item.public_children

    @item_docs = proc do |cate|
      @docs = Faq::Doc
              .published
              .agent_filter(request.mobile)
              .visible_in_list
              .category_is(cate)
              .order(published_at: :desc)
              .paginate(page: @page, per_page: @limit)
    end
  end
end
