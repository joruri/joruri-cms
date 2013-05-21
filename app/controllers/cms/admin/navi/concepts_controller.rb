# encoding: utf-8
class Cms::Admin::Navi::ConceptsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  
  def index
    no_ajax = request.env['HTTP_X_REQUESTED_WITH'].to_s !~ /XMLHttpRequest/i
    render :layout => no_ajax
  end
  
  def show
    Core.concept_id = params[:id]
    session[:cms_concept] = Core.concept(:id)
    
    @item = Core.concept
  end
end
