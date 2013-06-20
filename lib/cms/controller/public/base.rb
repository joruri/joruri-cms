# encoding: utf-8
class Cms::Controller::Public::Base < Sys::Controller::Public::Base
  include Cms::Controller::Layout
  layout  'base'
  before_filter :initialize_params
  after_filter :render_public_variables
  after_filter :render_public_layout
  
  def initialize_params
    if !Core.user
      user = Sys::User.new
      user.id = 0
      Core.user = user
    end
    if !Core.user_group
      group = Sys::Group.new
      group.id = 0
      Core.user_group = group
    end
    
    #params.delete(:page)
    if Page.uri =~ /\.p[0-9]+\.html$/
      page = Page.uri.gsub(/.*\.p([0-9]+)\.html$/, '\\1')
      params[:page] = page.to_i if page !~ /^0+$/
    end
    
    ## response by storage
    if ::Storage.env == :db && Core.user.id == 0
      pc_view = (!request.mobile? && !request.smart_phone?) || cookies[:pc_view] == "on"
      
      ## valid redirect_uri
      if Core.request_uri =~ /\d{8}/ && pc_view
        uri =  Core.request_uri =~ /\/$/ ? "#{Core.request_uri}index.html" : Core.request_uri 
        Cms::Content.rewrite_regex(:site_id => Page.site.id).each do |src, dst|
          if uri =~ /#{src.gsub('/', '\\/')}/
            path = Page.site.public_path + uri.gsub(/#{src.gsub('/', '\\/')}/, dst.gsub('$', '\\'))
            return send_storage_file(path) if ::Storage.exists?(path)
          end
        end
      end
      
      path = "#{Page.site.public_path}" + Core.request_uri.gsub(/\/$/, "/index.html")
      return send_storage_file(path) if ::Storage.exists?(path) && pc_view
    end
  end
  
  def pre_dispatch
    ## each processes before dispatch
  end
  
  def render_public_variables
    
  end
end
