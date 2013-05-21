# encoding: utf-8
class Calendar::Public::Piece::DailyLinksController < Sys::Controller::Public::Base
  def index
    @content  = Calendar::Content::Base.find(Page.current_piece.content_id)
    @node     = @content.event_node
    
    @min_date = params[:calendar_event_min_date]
    @max_date = params[:calendar_event_max_date]
    @year     = params[:calendar_event_year]
    @month    = params[:calendar_event_month]
    
    if !@month || !@year
      today = Date.today
      @year  = today.strftime('%Y').to_i
      @month = today.strftime('%m').to_i
    end
    
    @sdate    = "#{@year}-#{@month}-01"
    @edate    = (Date.new(@year, @month, 1) >> 1).strftime('%Y-%m-%d')
    @calendar = Util::Date::Calendar.new(@year, @month)
    
    return unless @node
    
    @node_uri = @node.public_uri
    @calendar.year_uri  = "#{@node_uri}:year/"
    @calendar.month_uri = "#{@node_uri}:year/:month/"
    @calendar.day_uri   = "#{@node_uri}:year/:month/#day:day"
    
    item = Calendar::Event.new.public
    item.and :content_id, @content.id
    item.event_date_in(@sdate, @edate)
    events = item.find(:all, :order => 'event_date ASC, id ASC')
    
    sdate = Date.strptime(@sdate, "%Y-%m-%d")
    edate = Date.strptime(@edate, "%Y-%m-%d")
    dates = []
    (events + event_docs).each do |ev|
      dates << ev.event_date
      next if ev.event_close_date.blank?
      
      date = [sdate, ev.event_date].max
      term = [edate, ev.event_close_date].min
      while date <= term
        dates << date
        date = date + 1
      end
    end
    @calendar.day_link = dates
    
    if @min_date && @max_date
      @pagination = Util::Html::SimplePagination.new
      @pagination.prev_label = "&lt;前の月"
      @pagination.next_label = "次の月&gt;"
      @pagination.prev_uri   = @calendar.prev_month_uri if @calendar.prev_month_date >= @min_date
      @pagination.next_uri   = @calendar.next_month_uri if @calendar.next_month_date <= @max_date
    end
  end
  
protected
  def event_docs
    content_id = @content.setting_value(:doc_content_id)
    return [] if content_id.blank?
    
    doc = Article::Doc.new.public
    doc.agent_filter(request.mobile)
    doc.and :content_id, content_id
    doc.event_date_in(@sdate, @edate)
    doc.find(:all, :order => 'event_date')
  end
end
