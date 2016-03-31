# encoding: utf-8
class Bbs::Public::Node::ThreadsController < Cms::Controller::Public::Base
  include SimpleCaptcha::ControllerHelpers

  protect_from_forgery except: [:delete]

  def pre_dispatch
    @node     = Page.current_node
    @node_uri = @node.public_uri
    return http_error(404) unless @content = @node.content
    return http_error(404) if params[:thread] && params[:thread] !~ /^[0-9]+$/

    @admin_password  = @content.setting_value(:admin_password)
    @link_entry_form = @content.setting_value(:link_entry_form) == '1'
    @show_email      = @content.setting_value(:show_email) == '1'
    @show_uri        = @content.setting_value(:show_uri) == '1'
    @use_captcha     = @content.setting_value(:use_captcha) == '1'
    @use_password    = @content.setting_value(:use_password) == '1'
    @use_once_click  = @content.setting_value(:use_once_click) == '1'
    @block_uri       = @content.setting_value(:block_uri) == '1'
    @block_word      = @content.setting_value(:block_word)
    @block_ipaddr    = @content.setting_value(:block_ipaddr)
  end

  def index
    @item = Bbs::Item.new

    if request.post?
      return true if create
    elsif request.delete?
      return true if destroy
    end

    limit = request.mobile? ? 10 : 10
    limit = params[:limit] if params[:limit] && params[:limit].to_i < 100

    @threads = Bbs::Item
               .published
               .where(content_id: @content.id)
               .where(parent_id: 0)
               .order(id: :desc)
               .paginate(page: params[:page], per_apge: limit)
  end

  def new
    @item = Bbs::Item.new
    return true if request.post? && create
  end

  def show
    @item = Bbs::Item.new

    @thread = Bbs::Item
              .published
              .where(content_id: @content.id)
              .where(parent_id: 0)
              .where(thread_id: params[:thread])
              .order(id: :desc)
              .first
    return http_error(404) unless @thread

    if request.post?
      return true if create_res
    else
      @item.title = "Re: #{@thread.title}"
    end
  end

  def delete
    @item = Bbs::Item.new

    return true if request.delete? && destroy
  end

  protected

  def create
    @item.attributes   = params[:item]
    @item.content_id   = @content.id
    @item.parent_id    = 0
    @item.state        = 'public'
    @item.ipaddr       = request.remote_addr
    @item.user_agent   = request.user_agent
    @item.block_uri    = @block_uri
    @item.block_word   = @block_word
    @item.block_ipaddr = @block_ipaddr

    if @use_captcha
      return false unless @item.save_with_captcha
    else
      return false unless @item.save
    end

    flash[:notice] = "投稿が完了しました。"
    redirect_to @node_uri
    true
  end

  def create_res
    @item.attributes   = params[:item]
    @item.content_id   = @content.id
    @item.parent_id    = @thread.id
    @item.thread_id    = @thread.id
    @item.state        = 'public'
    @item.ipaddr       = request.remote_addr
    @item.user_agent   = request.user_agent
    @item.block_uri    = @block_uri
    @item.block_word   = @block_word
    @item.block_ipaddr = @block_ipaddr

    if @use_captcha
      return false unless @item.save_with_captcha
    else
      return false unless @item.save
    end

    flash[:notice] = "投稿が完了しました。"
    redirect_to "#{@node_uri}#{@thread.id}/?#{query}#top"
    true
  end

  def destroy
    items = Bbs::Item
            .published
            .where(content_id: @content.id)
            .where(id: params[:no])

    if @admin_password.blank? || @admin_password != params[:password]
      items = items.where(password: params[:password])
                   .where.not(pssword: nil)
                   .where.not('')
    end

    @entry = items.first

    unless @entry
      @delete_error = true
      return false
    end

    @entry.destroy

    flash[:notice] = "削除が完了しました。"
    respond_to do |format|
      format.html { redirect_to "#{@node_uri}#top" }
      format.xml  { head :ok }
    end

    true
  end
end
