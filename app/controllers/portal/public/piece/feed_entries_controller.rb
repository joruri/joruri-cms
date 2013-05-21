# encoding: utf-8
class Portal::Public::Piece::FeedEntriesController < Sys::Controller::Public::Base

  def pre_dispatch
    @piece   = Page.current_piece
    @piece   = Portal::Piece::FeedEntry.find(@piece.id)
    @item = Page.current_item
  end

  def index
    page = 1
    limit = 10
    @content = Portal::Content::FeedEntry.find(Page.current_piece.content_id)
    entry = Portal::FeedEntry.new.public
    entry.content_id = @content.id
    entry.agent_filter(request.mobile)
    entry.and "#{Cms::FeedEntry.table_name}.content_id", @content.id

    list_type = nil
    category = @piece.category
    texts = categories_text

    list_html = ''
    page_html = nil

    @mode = ''
    if category
      #portal group list
      @mode = 'group'

      @node = @content.category_node
      @node_uri = ""
      @node_uri = @node.public_uri if @node
      @node_uri += "#{category.name}/"
      list_type = :groups

    elsif texts.blank?
      #portal all group list
      @mode = 'entries'
      @node = @content.entry_node
      @node_uri = @node.public_uri if @node
      list_type = :docs

    else
      #article docs list
      @mode = 'article'
      #dummy
      category = Portal::Category.new({
        :state      => 'public',
        :sort_no    => 1,
        :content_id => @content.id,
        :level_no => 1,
        :name => 'dummy',
        :title => '',
        :entry_categories => texts.join("\n")
      })
      entry.category_is category
      list_type = :groups
      @node = true
      @node_uri = "feed.html"

      case params[:file]
      when 'feed'
        @mode = 'article_more'
        @more = true
        page = params[:page]
        limit = 50
      end
    end

    entry.page page, limit
    content = Portal::Content::Base.find_by_id(@content.id)
    @entries = entry.find_with_own_docs(content.doc_content, list_type, {:item => category})

    prev   = nil
    @items = []
    @entries.each do |entry|
      date = entry.entry_updated.strftime('%y%m%d')
      @items << {
        :date => (date != prev ? entry.entry_updated.strftime('%Y年%-m月%-d日') : nil),
        :entry  => entry
      }
      prev = date
    end

    if @mode == 'article'
      list_html = render_to_string :action => :orverride
      update_latest_docs(list_html, page_html)
      render :text => ''
    elsif @mode == 'article_more'
#      Page.content = render_to_string :action => :orverride
      list_html = render_to_string :action => :orverride
      update_latest_docs(list_html, page_html)
      render :text => ''
    end
  end

private
  def categories_text
    texts = []
    if @item.instance_of?(Article::Category)
      params[:controller] = "article/public/node/categories"
      texts << "分野/#{@item.node_label}"
      if !params[:attr].blank?
        attr = Article::Unit.new.public
        attr.and :name_en, params[:attr]
        return [] unless @attr = attr.find(:first, :order => :sort_no)
        texts << "組織/#{@attr.node_label}"
      end
    elsif @item.instance_of?(Article::Unit)
      params[:controller] = "article/public/node/units"
      texts << "組織/#{@item.node_label}"
      if !params[:attr].blank?
        attr = Article::Attribute.new.public
        attr.and :name, params[:attr]
        return [] unless @attr = attr.find(:first, :order => :sort_no)
        texts << "属性/#{@attr.node_label}"
      end
    elsif @item.instance_of?(Article::Attribute)
      params[:controller] = "article/public/node/attributes"
      texts << "属性/#{@item.node_label}"
      if !params[:attr].blank?
        attr = Article::Unit.new.public
        attr.and :name_en, params[:attr]
        return [] unless @attr = attr.find(:first, :order => :sort_no)
        texts << "組織/#{@attr.node_label}"
      end
    elsif @item.instance_of?(Article::Area)
      params[:controller] = "article/public/node/areas"
      texts << "地域/#{@item.node_label}"
      if !params[:attr].blank?
        attr = Article::Attribute.new.public
        attr.and :name, params[:attr]
        return [] unless @attr = attr.find(:first, :order => :sort_no)
        texts << "属性/#{@attr.node_label}"
      end
    end
    params[:action] = "show"
    texts
  end

  def update_latest_docs(list_html, page_html = nil)
    require "rexml/document"
    doc = REXML::Document.new(Page.content)
    doc.root.get_elements("div").each do |div|
      next unless div.attribute('class').to_s == 'latest'
      while div.delete_element("*") do ; end
      div.add_element REXML::Document.new(list_html)
      div.add_element REXML::Document.new(page_html) if page_html
    end
    Page.content = doc.to_s
  end
end
