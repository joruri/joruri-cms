# encoding: utf-8
class Calendar::Public::Piece::MonthlyLinksController < Sys::Controller::Public::Base
  def index
    @content  = Calendar::Content::Base.find(Page.current_piece.content_id)
    @node     = @content.event_node
    @node_uri = @node.public_uri if @node
    return render(:text => '') unless @node
    
    @min_date = params[:calendar_event_min_date]
    @max_date = params[:calendar_event_max_date]
    @year     = params[:calendar_event_year]
    @month    = params[:calendar_event_month]
    @links = []
    return render(:text => '') unless @min_date
    
    year = nil
    date = @min_date
    while date <= @max_date
      month = date.month
      if year != date.year
        year  = date.year
        ccls  = "year year#{year}"
        ccls += " current" if @year == date.year && @month.nil?
        @links << {
          :name  => date.strftime("%Y年"),
          :uri   => "#{@node_uri}#{year}/",
          :class => ccls
        }
      end
      ccls  = "month month#{month}"
      ccls += " current" if @year == date.year && @month == month
      @links << {
        :name  => date.strftime("%-m月"),
        :uri   => "#{@node_uri}#{year}/" + sprintf("%02d/", month),
        :class  => ccls
      }
      date = date >> 1
    end
  end
end
