# encoding: utf-8
class Cms::Admin::Node::PagesController < Cms::Admin::Node::BaseController
  def edit
    @item = model.new.find(params[:id])
    #return error_auth unless @item.readable?
    
    @item.in_inquiry = @item.default_inquiry(:state => "hidden") unless @item.inquiry
    
    @item.name ||= 'index.html'
    
    _show @item
  end
  
  def update
    @item = model.new.find(params[:id])
    @item.attributes = params[:item]
    @item.state      = "draft"
    @item.state      = "recognize" if params[:commit_recognize]
    @item.state      = "public"    if params[:commit_public]
    
    _update @item do
      send_recognition_request_mail(@item) if @item.state == 'recognize'
      publish_by_update(@item) if @item.state == 'public'
      @item.close if !@item.public?
      
      respond_to do |format|
        format.html { return redirect_to(cms_nodes_path) }
      end
    end
  end
  
  def recognize(item)
    _recognize(item, :location => cms_nodes_path) do
      if @item.state == 'recognized'
        send_recognition_success_mail(@item)
      end
    end
  end
  
  def publish_ruby(item)
    uri  = item.public_uri
    uri  = (uri =~ /\?/) ? uri.gsub(/(.*\.html)\?/, '\\1.r?') : "#{uri}.r"
    path = "#{item.public_path}.r"
    item.publish_page(render_public_as_string(uri, :site => item.site), :path => path, :uri => uri, :dependent => :ruby)
  end
  
  def publish(item)
    item.public_uri = "#{item.public_uri}?node_id=#{item.id}"
    _publish(item, :location => cms_nodes_path) { publish_ruby(item) }
  end
  
  def publish_by_update(item)
    item.public_uri = "#{item.public_uri}?node_id=#{item.id}"
    if item.publish(render_public_as_string(item.public_uri), :uri => item.public_uri)
      publish_ruby(item)
      flash[:notice] = "公開処理が完了しました。"
    else
      flash[:notice] = "公開処理に失敗しました。"
    end
  end
  
  def close(item)
    _close(item, :location => cms_nodes_path)
  end
  
  def duplicate(item)
    if dupe_item = item.duplicate
      flash[:notice] = '複製処理が完了しました。'
      respond_to do |format|
        format.html { redirect_to(cms_nodes_path) }
        format.xml  { head :ok }
      end
    else
      flash[:notice] = "複製処理に失敗しました。"
      respond_to do |format|
        format.html { redirect_to url_for(:action => :show) }
        format.xml  { render :xml => item.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def duplicate_for_replace(item)
    if dupe_item = item.duplicate(:replace)
      flash[:notice] = '複製処理が完了しました。'
      respond_to do |format|
        format.html { redirect_to(cms_nodes_path) }
        format.xml  { head :ok }
      end
    else
      flash[:notice] = "複製処理に失敗しました。"
      respond_to do |format|
        format.html { redirect_to url_for(:action => :show) }
        format.xml  { render :xml => item.errors, :status => :unprocessable_entity }
      end
    end
  end
  
protected
  def send_recognition_request_mail(item, users = nil)
    body = []
    body << "#{Core.user.name}さんより「#{item.title}」についての承認依頼が届きました。\n"
    body << "次の手順により，承認作業を行ってください。\n\n"
    body << "1. PC用記事のプレビューにより文書を確認\n"
    body << "#{item.preview_uri(:params => {:node_id => item.id})}\n\n"
    body << "2. 次のリンクから承認を実施\n"
    body << "#{url_for(:action => :show, :id => item)}\n"
    
    (users || item.recognizers).each do |user|
      send_mail({
        :to      => user.email,
        :from    => Core.user.email,
        :subject => "ページ 承認依頼メール | #{item.site.name}",
        :body    => body.join
      })
    end
  end

  def send_recognition_success_mail(item)
    return true unless item.recognition
    return true unless item.recognition.user
    return true if item.recognition.user.email.blank?

    task   = item.find_task_by_name('publish')
    notice = task.blank? ? "" : "直ちに公開する場合は"
    
    body = []
    body << "「#{item.title}」についての承認が完了しました。\n"
    body << "#{notice}次のURLをクリックして公開処理を行ってください。\n\n"
    body << "#{url_for(:action => :show, :id => item)}\n\n"
    body << "公開予定日時　#{task.strftime('%Y年%-m月%-d日 %H:%M')}\n" if !task.blank?
    
    send_mail({
      :from    => Core.user.email,
      :to      => item.recognition.user.email,
      :subject => "ページ 最終承認完了メール | #{item.site.name}",
      :body    => body.join
    })
  end
end
