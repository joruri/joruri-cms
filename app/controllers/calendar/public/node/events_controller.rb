# encoding: utf-8
class Calendar::Public::Node::EventsController < Cms::Controller::Public::Base
  include ActionView::Helpers::TextHelper
  helper Calendar::EventHelper
  
  def pre_dispatch
    @node     = Page.current_node
    @node_uri = @node.public_uri
    return http_error(404) unless @content = @node.content
    
    @list_type = @node.setting_value(:list_type)
    
    @today     = Date.today
    @min_date  = Date.new(@today.year, @today.month, 1) << 0
    @max_date  = Date.new(@today.year, @today.month, 1) >> 11
  end
  
  def index
    params[:year]  = @today.strftime("%Y").to_s
    params[:month] = @today.strftime("%m").to_s
    return index_monthly
  end
  
  def index_monthly
    return http_error(404) unless validate_date
    return http_error(404) if Date.new(@year, @month, 1) < @min_date
    return http_error(404) if Date.new(@year, @month, 1) > @max_date
    
    @sdate = "#{@year}-#{@month}-01"
    @edate = (Date.new(@year, @month, 1) >> 1).strftime('%Y-%m-%d')
    
    @calendar = Util::Date::Calendar.new(@year, @month)
    @calendar.month_uri = "#{@node_uri}:year/:month/"
    
    @pagination = Util::Html::SimplePagination.new
    @pagination.prev_label = "&lt;前の月"
    @pagination.next_label = "次の月&gt;"
    @pagination.prev_uri   = @calendar.prev_month_uri if @calendar.prev_month_date >= @min_date
    @pagination.next_uri   = @calendar.next_month_uri if @calendar.next_month_date <= @max_date
    
    @items = {}
    @calendar.days.each{|d| @items[d[:date]] = [] if d[:month].to_i == @month }
    
    item = Calendar::Event.new.public
    item.and :content_id, @content.id
    item.and :event_date, "IS NOT", nil
    item.event_date_in(@sdate, @edate)
    events = item.find(:all, :order => 'event_date, event_close_date, id')
    
    ## イベント別
    if @list_type == "each_event"
      make_docs_each_evnet(events)
      return render(:action => "index_event_monthly")
    end
    
    ## 日別
    events = (events + event_docs)
    events.sort! {|a, b| a.event_date <=> b.event_date }
    events.each do |ev|
      next if !@items[ev.event_date.to_s]
      @items[ev.event_date.to_s] << ev
    end
    
    render :action => "index_monthly"
  end
  
  def index_yearly
    return http_error(404) unless validate_date
    return http_error(404) if @year < @min_date.year
    return http_error(404) if @year > @max_date.year
    
    @sdate = "#{@year}-01-01"
    @edate = (Date.new(@year, 1, 1) >> 12).strftime('%Y-%m-%d')
    
    @days  = []
    @items = {}
    @wdays = Util::Date::Calendar.wday_specs
    
    @pagination = Util::Html::SimplePagination.new
    @pagination.prev_label = "&lt;前の年"
    @pagination.next_label = "次の年&gt;"
    @pagination.prev_uri   = "#{@node_uri}#{@year - 1}/" if (@year - 1) >= @min_date.year
    @pagination.next_uri   = "#{@node_uri}#{@year + 1}/" if (@year + 1) <= @max_date.year
    
    item = Calendar::Event.new.public
    item.and :content_id, @content.id
    item.event_date_in(@sdate, @edate)
    events = item.find(:all, :order => 'event_date, event_close_date, id')
    
    ## イベント別
    if @list_type == "each_event"
      make_docs_each_evnet(events)
      return render(:action => "index_event_yearly")
    end
    
    ## 日別
    events = (events + event_docs)
    events.sort! {|a, b| a.event_date <=> b.event_date }
    events.each do |ev|
      unless @items.key?(ev.event_date.to_s)
        date = ev.event_date
        wday = @wdays[date.strftime("%w").to_i]
        day  = {
          :date_object => date,
          :date        => date.to_s,
          :class       => "day #{wday[:class]}",
          :wday_label  => wday[:label],
          :holiday     => Util::Date::Holiday.holiday?(date.year, date.month, date.day) || nil
        }
        day[:class] += " holiday" if day[:holiday]
        @days << day
        @items[ev.event_date.to_s] = []
      end
      @items[ev.event_date.to_s] << ev
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
    doc.find(:all, :order => 'event_date, event_close_date')
  end
  
  def validate_date
    @month = params[:month]
    @year  = params[:year]
    return false if !@month.blank? && @month !~ /^(0[1-9]|10|11|12)$/
    return false if !@year.blank? && @year !~ /^[1-9][0-9][0-9][0-9]$/
    @year  = @year.to_i
    @month = @month.to_i if @month
    params[:calendar_event_year]  = @year
    params[:calendar_event_month] = @month
    params[:calendar_event_min_date] = @min_date
    params[:calendar_event_max_date] = @max_date
    return true
  end
  
  def date_label(sdate, cdate)
    wdays = ["日", "月", "火", "水", "木", "金", "土"]
    
    date = %Q(<span class="startDate">#{sdate.strftime('%Y年%-m月%-d日')}（#{wdays[sdate.wday]}）</span>)
    if cdate
      date += %Q(<span class="from">～</span>) 
      date += %Q(<span class="closeDate">#{cdate.strftime('%-m月%-d日')}（#{wdays[cdate.wday]}）</span>)
    end
    date.html_safe
  end
  
  ## イベント別
  def make_docs_each_evnet(events)
    @items = []
    
    preset = {
      :title => nil, :body => nil, :uri => nil,
      :event_date => nil, :event_close_date => nil, :thumbnail => nil,
    }
    
    events.each do |ev|
      @items << preset.merge({
        :title => ev.title,
        :body  => ev.body.to_s.gsub(/<("[^"]*"|'[^']*'|[^'">])*>/, "").gsub(/\r\n|\r|\n/, '<br />'),
        :uri => ev.event_uri,
        :event_date => ev.event_date,
        :close_date => ev.event_close_date,
        :date_label => date_label(ev.event_date, ev.event_close_date),
        :thumb => nil,
      })
    end
    
    event_docs.each do |ev|
      @items << preset.merge({
        :title => ev.title,
        :body  => truncate(ev.summary_body, :length => 50),
        :uri => ev.public_uri,
        :event_date => ev.event_date,
        :close_date => ev.event_close_date,
        :date_label => date_label(ev.event_date, ev.event_close_date),
        :thumb => ev.thumbnail_file,
        :thumb_uri => ev.thumbnail_uri,
      })
    end
    
    @items.sort! {|a, b| a[:event_date] <=> b[:event_date] }
  end
end