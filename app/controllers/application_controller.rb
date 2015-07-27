# encoding: utf-8
class ApplicationController < ActionController::Base
  include Cms::Controller::Public
  helper  FormHelper
  helper  LinkHelper
  protect_from_forgery # :secret => '1f0d667235154ecf25eaf90055d99e99'
  before_filter :initialize_application
#  rescue_from Exception, :with => :rescue_exception
  
  def initialize_application
    if Core.publish
      Page.mobile = nil
      unset_mobile
    else
      Page.mobile = true if request.mobile?
      set_mobile if Page.mobile? && !request.mobile?
    end
    return false if Core.dispatched?
    return Core.dispatched
  end
  
  def query(params = nil)
    Util::Http::QueryString.get_query(params)
  end
  
  def skip_layout
    self.class.layout 'base'
  end
  
  def send_mail(params)
    return false if params[:from].blank?
    return false if params[:to].blank?
    ApplicationMailer.send_mail(params).deliver
  end
  
  def send_storage_file(path, options = {})
    options[:type]        ||= ::Storage.mime_type(path)
    options[:filename]    ||= ::File.basename(path)
    options[:disposition] ||= :inline
    send_data(::Storage.binread(path), :type => options[:type], :filename => options[:filename], :disposition => options[:disposition])
  end
  
  def set_mobile
    def request.mobile
      Jpmobile::Mobile::Au.new(nil, nil)
    end
  end
  
  def unset_mobile
    def request.mobile
      nil
    end
  end
  
private
  def rescue_action(error)
    case error
    when ActionController::InvalidAuthenticityToken
      http_error(422, "Invalid Authenticity Token")
    when ActionView::MissingTemplate
      RAILS_ENV == "production" ? http_error(404) : super
    else
      super
    end
  end
  
  ## Production && local
  def rescue_action_in_public(exception)
    http_error(500, nil)
  end
  
  def http_error(status, message = nil)
    erase_render_results rescue nil
    Page.error = status
    
    if status == 404
      if Page.site && !request.mobile?
        file  = "#{Page.site.public_path}#{Core.request_uri}"
        file += "index.html" if file =~ /\/$/
        if ::Storage.exists?(file)
          mime = ::Storage.mime_type(file) || "text/html"
          return send_data(::Storage.binread(file),  :type => mime, :filename => ::File.basename(file), :disposition => :inline)
        end
      end
      message ||= "ページが見つかりません。"
    end
    
    name    = Rack::Utils::HTTP_STATUS_CODES[status]
    name    = " #{name}" if name
    message = " ( #{message} )" if message
    message = "#{status}#{name}#{message}"
    
    if Core.mode =~ /^(admin|script)$/ && status != 404
      error_log("#{status} #{request.env['REQUEST_URI']}") if status != 404
      return respond_to do |format|
        format.html { render :status => status, :text => "<p>#{message}</p>", :layout => "admin/cms/error" }
        format.xml  { render :status => status, :xml => "<errors><error>#{message}</error></errors>" }
      end
    end
    
    ## render mp3
    if Core.request_uri =~ /\.html(\.r)?\.mp3/
      path   = ::File.join(Page.site.public_path, Core.request_uri)
      path   = path.gsub(/\.html\.r\.mp3$/, '.html.mp3')
      files  = []
      files << "#{Page.site.public_path}404.html.mp3"
      files << "#{Rails.root}/public/404.html.mp3"
      files.each {|file| return send_storage_file(file) if ::Storage.exists?(file) }
    end
    
    ## render
    files = []
    files << "#{Page.site.public_path}/#{status}.html" if Page.site
    files << "#{Core.site.public_path}/#{status}.html" if Core.site
    files << "#{Rails.public_path}/#{status}.html"
    files << "#{Rails.public_path}/500.html"
    
    html = nil
    files.each {|file| html = ::Storage.read(file) if html.nil? && ::Storage.exists?(file) }
    html ||= "<html>\n<head><title>#{status}</title></head>\n<body>\n<p>#{message}</p>\n</body>\n</html>\n"
    
    if request.format.to_s =~ /xml/i
      render :status => status, :xml => "<errors><error>#{message}</error></errors>"
    else
      cookies.delete(:navigation_ruby) if Core.request_uri =~ /\.html\.r$/ && cookies[:navigation_ruby]
      render :status => status, :inline => html.html_safe
    end
  end

  def envs_to_request_as_smart_phone
    return @envs_to_request_as_smart_phone if @envs_to_request_as_smart_phone
    user_agent = 'Mozilla/5.0 (iPhone; CPU iPhone OS 7_1_1 like Mac OS X) AppleWebKit/537.51.2 (KHTML, like Gecko) Version/7.0 Mobile/11D201 Safari/9537.53'
    jpmobile = Jpmobile::Mobile::AbstractMobile.carrier('HTTP_USER_AGENT' => user_agent)
    @envs_to_request_as_smart_phone = {'HTTP_USER_AGENT' => user_agent, 'rack.jpmobile' => jpmobile}
  end

end
