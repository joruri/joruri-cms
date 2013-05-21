# encoding: utf-8
class Article::Public::Piece::CalendarsController < Sys::Controller::Public::Base
  def index
    if params[:year] && params[:month]
      @calendar = Util::Date::Calendar.new params[:year].to_i, params[:month].to_i
    else
      @calendar = Util::Date::Calendar.new
    end
    
    @content = Article::Content::Doc.find(Page.current_piece.content_id)
    @node = @content.event_node
    
    uri = @node ? @node.public_uri : '/'
    @calendar.year_uri  = "#{uri}:year/"
    @calendar.month_uri = "#{uri}:year/:month/"
    @calendar.day_uri   = "#{uri}:year/:month/#day:day"
    
    @sdate = "#{@calendar.year}-#{@calendar.month}-01"
    @edate = (Date.new(@calendar.year, @calendar.month, 1) >> 1).strftime('%Y-%m-%d')
    
    sdate = Date.strptime(@sdate, "%Y-%m-%d")
    edate = Date.strptime(@edate, "%Y-%m-%d")
    dates = []
    
    if @node
      doc = Article::Doc.new.public
      doc.agent_filter(request.mobile)
      doc.and :content_id, @content.id
      #doc.event_date_is(:year => @calendar.year, :month => @calendar.month)
      #docs = doc.find(:all, :select => 'event_date', :group => :event_date)
      doc.event_date_in(@sdate, @edate)
      docs = doc.find(:all, :select => 'event_date, event_close_date')
      docs.each do |doc|
        dates << doc.event_date
        next if doc.event_close_date.blank?
        
        date = [sdate, doc.event_date].max
        term = [edate, doc.event_close_date].min
        while date <= term
          dates << date
          date = date + 1
        end
      end
    end
    
    @calendar.day_link = dates
    
    now = Time.now
    min = "#{now.year - 1}#{format('%02d', now.month)}".to_i
    max = "#{now.year + 1}#{format('%02d', now.month)}".to_i
    cym = "#{@calendar.year}#{format('%02d', @calendar.month)}".to_i
    @calendar.prev_month_uri = false if cym <= min
    @calendar.next_month_uri = false if cym >= max
  end
end
