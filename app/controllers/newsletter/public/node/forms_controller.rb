# encoding: utf-8
class Newsletter::Public::Node::FormsController < Cms::Controller::Public::Base

  def pre_dispatch
    return http_error(404) unless content = Page.current_node.content
    
    @content     = Newsletter::Content::Base.find_by_id(content.id)
    @node        = Page.current_node
    @node_uri    = @node.public_uri
    @use_captcha = @content.setting_value(:use_captcha) == "1"
  end

  def index
    @item = Newsletter::Request.new
    return true unless request.post?
    
    ## subscribe
    @item.attributes   = params[:item]
    @item.state        = "enabled"
    @item.content_id   = @content.id
    @item.request_type = "subscribe"
    @item.ipaddr       = request.remote_addr
    
    if @use_captcha
      return redirect_to("#{@node_uri}sent.html?subscribe") if @item.save_with_captcha
    else
      return redirect_to("#{@node_uri}sent.html?subscribe") if @item.save
    end
  end

  def sent
    #
  end
  
  def change
    @item = Newsletter::Request.new
    return true unless request.post?
    
    ## unsubscribe
    @item.attributes   = params[:item]
    @item.state        = "enabled"
    @item.content_id   = @content.id
    @item.request_type = "unsubscribe"
    @item.ipaddr       = request.remote_addr
    
    if @use_captcha
      return redirect_to("#{@node_uri}sent.html?unsubscribe") if @item.save_with_captcha
    else
      return redirect_to("#{@node_uri}sent.html?unsubscribe") if @item.save
    end
  end
end
