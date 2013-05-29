# encoding: utf-8
class Cms::Controller::Admin::Base < Sys::Controller::Admin::Base
  include Cms::Controller::Layout
  helper Cms::FormHelper
  layout  'admin/cms'
  
  def default_url_options
    Core.concept ? { :concept => Core.concept.id } : {}
  end
  
  def initialize_application
    return false unless super
    
    if cookies[:cms_site] && !Core.site
      cookies.delete(:cms_site)
      session.delete(:cms_concept)
      return redirect_to "#{Joruri.admin_uri}/logout"
    end
    
    if Core.user
      if params[:concept]
        Core.concept_id = params[:concept]
      elsif Core.request_uri == "#{Joruri.admin_uri}"
        Core.concept_id = 0
        session[:cms_concept] = Core.concept(:id)
      else
        Core.concept_id = session[:cms_concept]
      end
    end
    
    return true
  end
end