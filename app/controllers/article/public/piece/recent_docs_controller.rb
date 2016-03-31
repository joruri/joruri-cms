# encoding: utf-8
class Article::Public::Piece::RecentDocsController < Sys::Controller::Public::Base
  helper Article::DocHelper

  def index
    @content = Article::Content::Doc.find(Page.current_piece.content_id)
    @node    = @content.recent_node
    @piece   = Page.current_piece

    @more_label = @piece.setting_value(:more_label)
    @more_label = ">>新着記事一覧" if @more_label.blank?

    limit = Page.current_piece.setting_value(:list_count)
    limit = (limit.to_s =~ /^[1-9][0-9]*$/) ? limit.to_i : 10

    @docs = Article::Doc
            .published
            .agent_filter(request.mobile)
            .where(content_id: @content.id)
            .visible_in_recent
            .order(published_at: :desc)
            .paginate(page: 1, per_page: limit)

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
end
