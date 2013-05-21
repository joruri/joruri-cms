# encoding: utf-8
class Cms::Public::Node::PagesController < Cms::Controller::Public::Base
  
  def index
    @item = Cms::Node::Page.find(Page.current_node.id)
    
    if Core.mode == 'preview' && params[:node_id]
      cond = {:id => params[:node_id], :parent_id => @item.parent_id, :name => @item.name}
      return http_error(404) unless @item = Cms::Node::Page.find(:first, :conditions => cond)
    end
    
    Page.current_node = @item
    Page.current_item = @item
    Page.title        = @item.title
    
    @body = @item.body
    
    if request.mobile?
      Page.title = @item.mobile_title if !@item.mobile_title.blank?
      @body = @item.mobile_body if !@item.mobile_body.blank?
    end
  end
  
protected
  def render_public_variables
    response.body.scan(/\{\$[a-z]+\}/i).uniq.each do |name|
      value = name
      if name == "{$publishedOn}"
        value = @item.published_at ? @item.published_at.strftime("%Y年%-m月%-d日") : ""
      end
      
      response.body.gsub!("#{name}", value) if name != value
    end
  end
end
