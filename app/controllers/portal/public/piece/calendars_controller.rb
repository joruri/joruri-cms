# encoding: utf-8
class Portal::Public::Piece::CalendarsController < Sys::Controller::Public::Base
  def index
    if params[:year] && params[:month]
      @calendar = Util::Date::Calendar.new params[:year].to_i, params[:month].to_i
    else
      @calendar = Util::Date::Calendar.new
    end

    @content = Portal::Content::FeedEntry.find(Page.current_piece.content_id)
    @node = @content.event_node

    uri = @node ? @node.public_uri : '/'
    @calendar.year_uri  = "#{uri}:year/"
    @calendar.month_uri = "#{uri}:year/:month/"
    @calendar.day_uri   = "#{uri}:year/:month/#day:day"

    dates = []
    if @node
      #feeds
      entry = Portal::FeedEntry.new.public
      entry.agent_filter(request.mobile)
      entry.and "#{Cms::FeedEntry.table_name}.content_id", @content.id
      entry.event_date_is(:year => @calendar.year, :month => @calendar.month)
      entries = entry.find(:all, :select => 'event_date', :group => :event_date)
      entries.each{|entry| dates << entry.event_date}

      #docs
      base_content = Portal::Content::Base.find_by_id(@content.id)
      if doc_content = base_content.doc_content
        doc = Article::Doc.new.public
        doc.agent_filter(request.mobile)
        doc.and :content_id, doc_content.id
        doc.event_date_is(:year => @calendar.year, :month => @calendar.month)
        docs = doc.find(:all, :select => 'event_date', :group => :event_date)
        docs.each{|doc| dates << doc.event_date}
      end
    end

    @calendar.day_link = dates
  end
end
