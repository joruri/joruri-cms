# encoding: utf-8
class Cms::Script::LinkChecksController < Cms::Controller::Script::Publication
  
  def check
    options = Script.options
    
    @site_uri = {}
    
    pub = Sys::Publisher.new
    pub.and :site_id, options[:site_id] if options[:site_id]
    pub.and :uri, 'IS NOT', nil
    pub.and do |c|
      c.or :internal_links, 'IS NOT', nil
      c.or :external_links, 'IS NOT', nil
    end
    pubs = pub.find(:all, :select => :id)
    
    Script.total pubs.size
    
    logs = {}
    
    pubs.each_with_index do |v, idx|
      pub = Sys::Publisher.find_by_id(v[:id])
      next unless pub
      
      Script.current
      
      begin
        links  = pub.internal_links.to_s.split(/\n/)
        links += pub.external_links.to_s.split(/\n/) if options[:external]
        
        links.each do |uri|
          next if uri.blank?
          
          if !@site_uri[pub.site_id]
            site = Cms::Site.find(pub.site_id)
            @site_uri[pub.site_id] = site.full_uri.gsub(/^(.*?\/\/.*?\/).*/, '\\1')
          end
          
          uri = ::File.join(@site_uri[pub.site_id], uri) if uri !~ /^https?:\/\//
          
          logs[uri] ||= { :count => 0 }
          
          log = logs[uri]
          log[:count]   += 1
          log[:source] ||= ::File.join(@site_uri[pub.site_id], pub.uri)
          
          if !log[:state]
            if ::Util::Http.exists?(uri)
              log[:state] = 'exists'
              Script.success
            else
              log[:state] = 'failed'
              Script.error "unreachable url: #{uri}"
            end
          end
        end
      rescue Script::InterruptException => e
        raise e
      rescue Exception => e
        Script.error e.to_s
      end
    end
    
    Cms::LinkCheck.connection.execute "TRUNCATE TABLE #{Cms::LinkCheck.table_name}"
    
    logs.each do |link, data|
      check = Cms::LinkCheck.new({
        :state        => data[:state],
        :link_uri     => link,
        :source_uri   => data[:source],
        :source_count => data[:count],
      })
      check.save
    end
    
    render :text => "OK"
  end
  
end
