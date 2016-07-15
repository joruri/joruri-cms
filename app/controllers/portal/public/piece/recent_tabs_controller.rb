# encoding: utf-8
class Portal::Public::Piece::RecentTabsController < Sys::Controller::Public::Base
  include Portal::Controller::Feed
  helper Portal::DocHelper

  def pre_dispatch
    @piece   = Page.current_piece
    @content = @piece.content
  end

  def index
    @content    = Portal::Content::FeedEntry.find(Page.current_piece.content_id)
    @more_label = @piece.setting_value(:more_label)
    @more_label = ">>新着記事一覧" if @more_label.blank?

    limit = Page.current_piece.setting_value(:list_count)
    limit = (limit.to_s =~ /^[1-9][0-9]*$/) ? limit.to_i : 10

    @tabs = []
    base_content = Portal::Content::Base.find_by(id: @content.id)

    feed = Portal::Piece::FeedEntry.find(@piece.id)
    Portal::Piece::RecentTabXml.find(:all, feed, order: :sort_no).each do |tab|
      next if tab.name.blank?

      current   = (@tabs.empty?) ? true : nil
      tab_class = tab.name
      tab_class = "#{tab.name} current" if current
      more_uri = tab.more.blank? ? nil : tab.more

      entries = []
      list = tab.category_items
      if list.size > 0
        entries = Portal::FeedEntry
                  .public_content_with_own_docs(
                    base_content,
                    :groups,
                    category: list[0],
                    mobile: request.mobile
                  )
                  .paginate(page: 1, per_page: limit)

        # more
        more_uri = "#{@content.category_node.public_uri}#{list[0].name}/" if !more_uri && @content.category_node && !entries.empty?
      else
        entries = Portal::FeedEntry
                  .public_content_with_own_docs(
                    base_content,
                    :docs,
                    mobile: request.mobile
                  )
                  .paginate(page: 1, per_page: limit)

        # more
        more_uri = @content.entry_node.public_uri if !more_uri && @content.entry_node && !entries.empty?
      end

      @tabs << {
        name: tab.name,
        title: tab.title,
        class: tab_class,
        more: more_uri,
        current: current,
        docs: entries
      }
    end

    return render text: '' if @tabs.empty?
  end
end
