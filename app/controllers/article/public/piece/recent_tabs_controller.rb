# encoding: utf-8
class Article::Public::Piece::RecentTabsController < Sys::Controller::Public::Base
  include Article::Controller::Feed

  def pre_dispatch
    @piece   = Page.current_piece
    @content = @piece.content
  end

  def index
    @more_label = @piece.setting_value(:more_label)
    @more_label = ">>新着記事一覧" if @more_label.blank?

    @list_type = @piece.setting_value(:list_type)

    @tabs = []

    limit = Page.current_piece.setting_value(:list_count)
    limit = (limit.to_s =~ /^[1-9][0-9]*$/) ? limit.to_i : 10

    Article::Piece::RecentTabXml.find(:all, @piece, order: :sort_no).each do |tab|
      next if tab.name.blank?

      current   = (@tabs.empty?) ? true : nil
      tab_class = tab.name
      tab_class = "#{tab.name} current" if current

      docs = Article::Doc
             .published
             .agent_filter(request.mobile)
             .where(content_id: @content.id)
             .visible_in_recent
             .group_is(tab)
             .order(published_at: :desc)
             .paginate(page: 1, per_page: limit)

      @tabs << {
        name: tab.name,
        title: tab.title,
        class: tab_class,
        more: (tab.more.blank? ? nil : tab.more),
        current: current,
        docs: docs
      }
    end

    return render text: '' if @tabs.empty?
  end
end
