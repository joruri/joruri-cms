# encoding: utf-8
class Cms::Admin::Tool::SearchController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:designer)
    return redirect_to(request.env['PATH_INFO']) if params[:reset]
  end

  def index
    @item  = []
    @items = []
    def @item.keyword
      @keyword
    end

    def @item.keyword=(v)
      @keyword = v
    end

    return true if params[:do] != 'search'
    return true if params[:item][:keyword].blank?
    @item.keyword = params[:item][:keyword]

    group = ["ページ", []]

    arel_nodes = Cms::Node.arel_table

    items = Cms::Node
            .where(site_id: Core.site.id)
            .where(model: 'Cms::Page')
            .where(arel_nodes[:body].matches("%#{@item.keyword}%")
                   .or(arel_nodes[:mobile_body].matches("%#{@item.keyword}%")))
            .order(:id)

    items.each { |c| group[1] << [c.id, "#{c.title} #{c.public_uri}"] }
    @items << group

    contents = Cms::Content
               .where(site_id: core.site.id)
               .where(model: 'Article::Doc')
               .order(:id)

    arel_docs = Article::Doc.arel_table

    contents.each do |content|
      group = ["自治体記事：#{content.name}", []]

      items = Article::Doc
              .where(content_id: content.id)
              .where(arel_docs[:body].matches("%#{@item.keyword}%")
                     .or(arel_docs[:mobile_body].matches("%#{@item.keyword}%")))
              .order(:id)

      items.each { |c| group[1] << [c.id, c.title] }
      @items << group
    end
  end
end
