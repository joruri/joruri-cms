# encoding: utf-8
class Calendar::Script::EventsController < Cms::Controller::Script::Publication
  def publish
    prev_manths = 0
    next_manths = 11
    
    today = Date.today
    year  = nil
    0.upto(next_manths) do |i|
      date = today >> i
      if year != date.year
        year = date.year
        uri  = "#{@node.public_uri}#{date.strftime('%Y/')}"
        path = "#{@node.public_path}#{date.strftime('%Y/')}"
        publish_page(@node, :uri => uri, :site => @site, :path => path, :dependent => "year#{year}")
      end
      uri  = "#{@node.public_uri}#{date.strftime('%Y/%m/')}"
      path = "#{@node.public_path}#{date.strftime('%Y/%m/')}"
      break if !publish_page(@node, :uri => uri, :site => @site, :path => path, :dependent => "month#{(0+i)}")
    end
    
    render :text => "OK"
  end
end
