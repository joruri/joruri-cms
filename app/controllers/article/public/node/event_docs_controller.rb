# encoding: utf-8
class Article::Public::Node::EventDocsController < Cms::Controller::Public::Base
  include Article::Controller::Feed
  
  def pre_dispatch
    @node      = Page.current_node
    return http_error(404) unless @content = @node.content
    
    @list_type = @node.setting_value(:list_type)
  end
  
  def month
    if params[:year] && params[:month]
      @calendar = Util::Date::Calendar.new params[:year].to_i, params[:month].to_i
    else
      @calendar = Util::Date::Calendar.new
    end
    return http_error(404) if @calendar.errors
    
    ## calendar
    base_uri = @node.public_uri
    @calendar.year_uri  = "#{base_uri}:year/"
    @calendar.month_uri = "#{base_uri}:year/:month/"
    @calendar.day_uri   = "#{base_uri}:year/:month/#day:day"
    
    @days = {}
    @calendar.days.each do |day|
      next if day[:class] =~ /Month/
      key = "#{sprintf('%02d', day[:month])}#{sprintf('%02d', day[:day])}"
      @days[key] = day
    end
    
    ## pagination
    now = Time.now
    min = "#{now.year - 1}#{format('%02d', now.month)}".to_i
    max = "#{now.year + 1}#{format('%02d', now.month)}".to_i
    cym = "#{@calendar.year}#{format('%02d', @calendar.month)}".to_i
    
    return http_error(404) if cym < min
    return http_error(404) if cym > max
    @prev_link = cym <= min ? false : true
    @next_link = cym >= max ? false : true
    
    @sdate = "#{@calendar.year}-#{@calendar.month}-01"
    @edate = (Date.new(@calendar.year, @calendar.month, 1) >> 1).strftime('%Y-%m-%d')
    
    ## docs
    @items = []
    prev   = nil
    item = Article::Doc.new.public
    item.agent_filter(request.mobile)
    item.and :content_id, Page.current_node.content.id
    #item.event_date_is(:year => @calendar.year, :month => @calendar.month)
    item.event_date_in(@sdate, @edate)
    docs = item.find(:all, :order => 'event_date')
    return true if render_feed(docs)
      
    docs.each do |doc|
      key  = doc.event_date.strftime('%m%d')
      day  = @days[key] || {}
      attr = doc.attribute_items[0]
      @items << {
        :date => date_label(doc.event_date, doc.event_close_date),
        :date_id    => "day#{day[:day]}",
        :date_class => day[:class],
        :attr_class => attr ? "attribute attribute#{attr.name.camelize}" : nil,
        :attr_title => attr ? attr.title : nil,
        :doc        => doc
      }
    end
    
    if @list_type == "blog"
      return render(:action => :month_blog)
    end
  end
  
  def schedule
    item = Article::Doc.new.public
    item.agent_filter(request.mobile)
    item.and :content_id, @content.id
    item.and :event_date, ">=", Core.now
    docs = item.find(:all, :order => 'event_date')
    return true if render_feed(docs)
    
    http_error(404)
  end
  
  def date_label(sdate, cdate)
    wdays = ["日", "月", "火", "水", "木", "金", "土"]
    
    date = %Q(<span class="startDate">#{sdate.strftime('%-m月%-d日')}（#{wdays[sdate.wday]}）</span>)
    if cdate
      date += %Q(<span class="from">～</span>) 
      date += %Q(<span class="closeDate">#{cdate.strftime('%-m月%-d日')}（#{wdays[cdate.wday]}）</span>)
    end
    date.html_safe
  end
end
