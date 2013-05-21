# encoding: utf-8
class Faq::Script::SearchDocsController < Cms::Controller::Script::Publication
  def self.publishable?
    false
  end
  
  def publish
    @node.close_page
    
    render :text => "OK"
  end
end
