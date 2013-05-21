# encoding: utf-8
class Portal::Public::Node::EventEntriesController < Cms::Controller::Public::Base
  include Portal::Controller::Feed

  def pre_dispatch
    return http_error(404) unless content = Page.current_node.content
    @content = Portal::Content::Base.find_by_id(content.id)
  end

  def month
    if params[:year] && params[:month]
      @calendar = Util::Date::Calendar.new params[:year].to_i, params[:month].to_i
    else
      @calendar = Util::Date::Calendar.new
    end
    return http_error(404) if @calendar.errors

    ## calendar
    base_uri = Page.current_node.public_uri
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

    ## entries
    @items = []
    prev   = nil
    item = Portal::FeedEntry.new.public
    item.agent_filter(request.mobile)
    item.and "#{Cms::FeedEntry.table_name}.content_id", @content.id
    item.event_date_is(:year => @calendar.year, :month => @calendar.month)
    item.page 0, 1000
    entries = item.find_with_own_docs(@content.doc_content, :events, :year => @calendar.year, :month => @calendar.month)

    return true if render_feed(entries)

    entries.each do |entry|
      key  = entry.event_date.strftime('%m%d')
      next unless day = @days[key]

      date   = nil
      anchor = nil
      if prev != key
        date   = request.mobile? ?
          "#{day[:month]}月#{day[:day]}日(#{day[:wday_label]})" :
          "#{day[:month]}月#{day[:day]}日（#{day[:wday_label]}）"
        anchor = %Q(<a id="day#{day[:day]}" name="day#{day[:day]}"></a>).html_safe
      end

      feed_class = entry.feed ? " source#{entry.feed.name.camelize}" : ""
      @items << {
        :date       => date,
        :anchor     => anchor,
        :date_class => day[:class],
        :source_class => "source#{feed_class}",
        :source_title => entry.source_title,
        :entry        => entry
      }
      prev = key
    end
  end
end
