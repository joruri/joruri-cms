# encoding: utf-8
class Article::Admin::DocsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  include Sys::Controller::Scaffold::Recognition
  include Sys::Controller::Scaffold::Publication
  helper Article::FormHelper

  def pre_dispatch
    return error_auth unless @content = Cms::Content.find(params[:content])
    return error_auth unless Core.user.has_priv?(:read, :item => @content.concept)
    #default_url_options[:content] = @content

    return redirect_to(request.env['PATH_INFO']) if params[:reset]
    
    @recognition_type = @content.setting_value(:recognition_type)
  end

  def index
    redirect_to article_edit_docs_path
  end

  def show
    @item = Article::Doc.new.find(params[:id])
    @item.unset_inquiry_email_presence if @item.unset_inquiry_email_presence?
    #return error_auth unless @item.readable?
    
    @item.recognition.type = @recognition_type if @item.recognition
    
    _show @item
  end

  def new
    @item = Article::Doc.new({
      :content_id     => @content.id,
      :state          => 'recognize',
      :notice_state   => 'hidden',
      :recent_state   => 'visible',
      :list_state     => 'visible',
      :event_state    => 'hidden',
      :sns_link_state => 'visible',
    })
    state = @content.setting_value(:inquiry_default_state)
    @item.in_inquiry = @item.default_inquiry(:state => (state.blank? ? "visible" : state))
    @item.in_recognizer_ids = @content.setting_value(:default_recognizers)
    @item.unset_inquiry_email_presence if @item.unset_inquiry_email_presence?
    
    ## add tmp_id
    unless params[:_tmp]
      return redirect_to url_for(:action => :new, :_tmp => Util::Sequencer.next_id(:tmp, :md5 => true))
    end
  end
  
  def create
    @item = Article::Doc.new(params[:item])
    @item.content_id = @content.id
    @item.state      = "draft"
    @item.state      = "recognize" if params[:commit_recognize]
    @item.state      = "public"    if params[:commit_public]
    @item.unset_inquiry_email_presence if @item.unset_inquiry_email_presence?
    
    ## convert sys urls
    unid = params[:_tmp] || @item.unid
    #@item.body = @item.body.gsub(::File.join(Core.site.full_uri, article_preview_doc_file_path(:parent => unid)), '.')
    
    ## link check
    @checker = Sys::Lib::Form::Checker.new
    if params[:link_check] == "1"
      @checker.check_link @item.body
      return render :action => :new
    elsif @item.state =~ /(recognize|public)/
      if @content.setting_value(:auto_link_check) != "disabled" && params[:link_check] != "0"
        @item.link_checker = @checker
      end
    end
    
    _create @item do
      @item.fix_tmp_files(params[:_tmp])
      @item.body = @item.body.gsub(article_preview_doc_file_path(:parent => unid) + '/', @item.public_uri)
      @item.save(:validate => false) if @item.changed?

      @item = Article::Doc.find_by_id(@item.id)
      send_recognition_request_mail(@item) if @item.state == 'recognize'
      publish_by_update(@item) if @item.state == 'public'
    end
  end

  def update
    @item = Article::Doc.new.find(params[:id])
    @item.attributes = params[:item]
    @item.state      = "draft"
    @item.state      = "recognize" if params[:commit_recognize]
    @item.state      = "public"    if params[:commit_public]
    @item.unset_inquiry_email_presence if @item.unset_inquiry_email_presence?

    ## convert sys urls
    unid = params[:_tmp] || @item.unid
    @item.body = @item.body.gsub(article_preview_doc_file_path(:parent => unid) + '/', @item.public_uri)
    
    ## link check
    @checker = Sys::Lib::Form::Checker.new
    if params[:link_check] == "1"
      @checker.check_link @item.body
      return render :action => :edit
    elsif @item.state =~ /(recognize|public)/
      if @content.setting_value(:auto_link_check) != "disabled" && params[:link_check] != "0"
        @item.link_checker = @checker
      end
    end
    
    _update(@item) do
      send_recognition_request_mail(@item) if @item.state == 'recognize'
      publish_by_update(@item) if @item.state == 'public'
      @item.close if !@item.public?
    end
  end
  
  def destroy
    @item = Article::Doc.new.find(params[:id])
    _destroy @item
  end

  def recognize(item)
    _recognize(item) do
      if @item.state == 'recognized'
        send_recognition_success_mail(@item)
      elsif @recognition_type == 'with_admin'
        if item.recognition.recognized_all?(false)
          users = Sys::User.find_managers
          send_recognition_request_mail(@item, users)
        end
      end
    end
  end
  
  def duplicate(item)
    if dupe_item = item.duplicate
      flash[:notice] = '複製処理が完了しました。'
      respond_to do |format|
        format.html { redirect_to url_for(:action => :index) }
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
    if item.editable? && dupe_item = item.duplicate(:replace)
      flash[:notice] = '複製処理が完了しました。'
      respond_to do |format|
        format.html { redirect_to url_for(:action => :index) }
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
  
  def publish_ruby(item)
    uri  = item.public_uri
    uri  = (uri =~ /\?/) ? uri.gsub(/\?/, 'index.html.r?') : "#{uri}index.html.r"
    path = "#{item.public_path}.r"
    item.publish_page(render_public_as_string(uri, :site => item.content.site),
      :path => path, :uri => uri, :dependent => :ruby)
  end
  
  def publish(item)
    item.public_uri = "#{item.public_uri}?doc_id=#{item.id}"
    _publish(item) { publish_ruby(item) }
  end

  def publish_by_update(item)
    item.public_uri = "#{item.public_uri}?doc_id=#{item.id}"
    if item.publish(render_public_as_string(item.public_uri))
      publish_ruby(item)
      flash[:notice] = "公開処理が完了しました。"
    else
      flash[:notice] = "公開処理に失敗しました。"
    end
  end
  
protected
  def send_recognition_request_mail(item, users = nil)
    body = []
    body << "#{Core.user.name}さんより「#{item.title}」についての承認依頼が届きました。\n"
    body << "次の手順により，承認作業を行ってください。\n\n"
    body << "1. PC用記事のプレビューにより文書を確認\n"
    body << "#{item.preview_uri(:params => {:doc_id => item.id})}\n\n"
    body << "2. 次のリンクから承認を実施\n"
    body << "#{Core.site.admin_uri(:path => article_all_doc_path(:id => item.id))}\n"
    
    (users || item.recognizers).each do |user|
      send_mail({
        :to      => user.email,
        :from    => Core.user.email,
        :subject => "#{item.content.name} 承認依頼メール | #{item.content.site.name}",
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
    body << "#{Core.site.admin_uri(:path => article_all_doc_path(:id => item.id))}\n\n"
    body << "公開予定日時　#{task.strftime('%Y年%-m月%-d日 %H:%M')}\n" if !task.blank?
    
    send_mail({
      :from    => Core.user.email,
      :to      => item.recognition.user.email,
      :subject => "#{item.content.name} 最終承認完了メール | #{item.content.site.name}",
      :body    => body.join
    })
  end
end
