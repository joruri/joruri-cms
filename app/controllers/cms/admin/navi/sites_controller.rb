# encoding: utf-8
class Cms::Admin::Navi::SitesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  
  def index
    item = Cms::Site.new
    #item.or :admin_full_uri, "IS", nil
    #item.or :admin_full_uri, "LIKE", "http://#{request.env['HTTP_HOST']}/%"
    @sites = item.find(:all, :order => :id)

    no_ajax = request.env['HTTP_X_REQUESTED_WITH'].to_s !~ /XMLHttpRequest/i
    render :layout => no_ajax
  end
  
  def show
    site = Cms::Site.find_by_id(params[:id])
    if site
      if site.admin_full_uri.to_s != Core.site.admin_full_uri.to_s
        cookies.delete :cms_site
        return redirect_to ::File.join(site.admin_full_uri.to_s, Joruri.admin_uri)
      end
      cookies[:cms_site] = { :value => site.id, :path => '/', :expires => (Time.now + 60*60*24*7) }
    else
      cookies.delete :cms_site
    end
    session.delete(:cms_concept)
    return redirect_to "#{Joruri.admin_uri}"
  end
end
