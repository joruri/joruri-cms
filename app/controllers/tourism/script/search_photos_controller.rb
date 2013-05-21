# encoding: utf-8
class Tourism::Script::SearchPhotosController < Cms::Controller::Script::Publication
  def self.publishable?
    false
  end
  
  def publish
    @node.close_page
    
    render :text => "OK"
  end
end
