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
    
    @item.attributes   = params[:item]
    @item.state        = "enabled"
    @item.content_id   = @content.id
    @item.request_type = "subscribe"
    @item.ipaddr       = request.remote_addr
    
    valid = @use_captcha ? @item.valid_with_captcha? : @item.valid?
    return unless valid
    
    begin
      send_mail({
        :from    => @content.mail_from,
        :to      => @item.email,
        :subject => "#{@content.name}登録のご案内",
        :body    => @item.subscribe_guide_body,
      })
    rescue Exception => e
      return render(:text => "処理に失敗しました。")
    end
    
    redirect_to "#{@node_uri}sent.html"
  end

  def change
    @item = Newsletter::Request.new
    return true unless request.post?
    
    @item.attributes   = params[:item]
    @item.state        = "enabled"
    @item.content_id   = @content.id
    @item.request_type = "unsubscribe"
    @item.ipaddr       = request.remote_addr
    
    valid = @use_captcha ? @item.valid_with_captcha? : @item.valid?
    return unless valid
    
    begin
      send_mail({
        :from    => @content.mail_from,
        :to      => @item.email,
        :subject => "#{@content.name}解除のご案内",
        :body    => @item.unsubscribe_guide_body,
      })
    rescue Exception => e
      return render(:text => "処理に失敗しました。")
    end
    
    redirect_to "#{@node_uri}sent.html"
  end
  
  def sent
    #
  end
  
  def subscribe
    return http_error(404) if params[:email].to_s !~ /^[^\/]+\/[^\/]+$/
    
    email = params[:email].gsub(/\/.*/, '')
    hash  = params[:email].gsub(/.*\//, '')
    type  = params[:type]
    
    @item = Newsletter::Request.new
    @item.email        = email
    @item.letter_type  = @item.letter_types.collect{|v, k| k }.index(type) ? type : "pc_text"
    @item.state        = "enabled"
    @item.content_id   = @content.id
    @item.request_type = "subscribe"
    @item.ipaddr       = request.remote_addr
    
    return http_error(404) if hash != @item.email_hash
    return unless request.post?
    
    return redirect_to("#{@node_uri}sent.html?subscribe") if @item.save # @item.save_with_captcha
  end
  
  def unsubscribe
    return http_error(404) if params[:email].to_s !~ /^[^\/]+\/[^\/]+$/
    
    email = params[:email].gsub(/\/.*/, '')
    hash  = params[:email].gsub(/.*\//, '')
    type  = params[:type]
    
    @item = Newsletter::Request.new
    @item.email        = email
    @item.state        = "enabled"
    @item.content_id   = @content.id
    @item.request_type = "unsubscribe"
    @item.ipaddr       = request.remote_addr
    
    return http_error(404) if hash != @item.email_hash
    return unless request.post?
    
    return redirect_to("#{@node_uri}sent.html?unsubscribe") if @item.save # @item.save_with_captcha
  end
end
