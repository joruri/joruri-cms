# encoding: utf-8
class Article::Public::Node::DocsController < Cms::Controller::Public::Base
  include Article::Controller::Feed

  def pre_dispatch
    @node = Page.current_node
    @content = @node.content
    return http_error(404) unless @content
  end

  def index
    @docs = Article::Doc
            .published
            .agent_filter(request.mobile)
            .where(content_id: @content.id)
            .where(language_id: 1)
            .visible_in_list
            .search(params)
            .paginate(page: params[:page],
                      per_page: (request.mobile? ? 20 : 50))
            .order(published_at: :desc)
    return true if render_feed(@docs)

    if @docs.current_page > 1 && @docs.current_page > @docs.total_pages
      return http_error(404)
    end

    prev   = nil
    @items = []
    @docs.each do |doc|
      date = doc.published_at.strftime('%y%m%d')
      @items << {
        date: (date != prev ? doc.published_at.strftime('%Y年%-m月%-d日') : nil),
        doc: doc
      }
      prev = date
    end
  end

  def show
    docs = Article::Doc
           .public_or_preview
           .where(content_id: Page.current_node.content.id)
           .where(name: params[:name])
    docs = docs.agent_filter(request.mobile) if Core.mode != 'preview'

    @item = docs.first
    return http_error(404) unless @item

    if Core.mode == 'preview' && params[:doc_id]
      @item = Article::Doc.find_by(
        id: params[:doc_id],
        content_id: @item.content_id,
        name: @item.name
      )
      return http_error(404) unless @item
    end

    Page.current_item = @item
    Page.title        = @item.title

    if @node.setting_value(:show_concept_id)
      @item.concept_id = @node.setting_value(:show_concept_id)
    end

    if @node.setting_value(:show_layout_id)
      @item.layout_id  = @node.setting_value(:show_layout_id)
    end

    unit = @item.unit
    Page.add_body_class "unit#{unit.name.camelize}" if unit

    @item.category_items.each do |c|
      Page.add_body_class "cate#{c.name.camelize}"
    end

    @item.attribute_items.each do |c|
      Page.add_body_class "attr#{c.name.camelize}"
    end

    @item.area_items.each do |c|
      Page.add_body_class "area#{c.name.camelize}"
    end

    @body = @item.body

    if request.mobile?
      unless @item.mobile_body.blank?
        @body = @item.mobile_body
        @body = ApplicationController.helpers.br(@body)
      end

      related_sites = Page.site.related_sites(include_self: true)

      ## Converts the links.
      @body.gsub!(/<a .*?href=".*?".*?>.*?<\/a>/im) do |m|
        uri   = m.gsub(/<a .*?href="(.*?)".*?>.*?<\/a>/im, '\1')
        label = m.sub(/(<a .*?href=".*?".*?>)(.*?)(<\/a>)/i, '\2')

        if m =~ /^<a .*?class="iconFile.*?"/i
          ## attachment
          size = label.gsub(/.*(\(.*?\))$/, '\1')
          ext  = label.gsub(/.*\.(.*?)\(.*?\)$/, '\1').to_s.upcase
          "#{ext}ファイル#{size}"
        elsif uri =~ /\.(pdf|doc|docx|xls|xlsx|jtd|jst)$/i
          ## other than html file
          label
        elsif uri =~ /^(\/|\.\/|\.\.\/)/
          ## same site
          m
        else
          result = false
          related_sites.each do |site|
            result = true if uri + '/' =~ /^#{site}/i
            result = true if uri =~ /^[0-9a-z]/i && uri !~ /^(http|https):\/\//
            break if result
          end
          result ? m : label
        end
      end

      ## Converts the phone number texts.
      @body.gsub!(/[\(]?(([0-9]{2}[-\(\)]+[0-9]{4})|([0-9]{3}[-\(\)]+[0-9]{3,4})|([0-9]{4}[-\(\)]+[0-9]{2}))[-\)]+[0-9]{4}/) do |m|
        "<a href='tel:#{m.gsub(/\D/, '\1')}'>#{m}</a>"
      end
    end

    if Core.mode == 'preview' && !Core.publish
      if params[:doc_id]
        [/(<img[^>]+src="[\.\/]*?files\/.*?)(".*?>)/i,
         /(<a[^>]+href="[\.\/]*?files\/.*?)(".*?>)/i].each do |_regexp|
          @body = @body.gsub(
            _regexp,
            '\\1' + "?doc_id=#{params[:doc_id]}" + '\\2'
          )
        end
      end
    end
  end
end
