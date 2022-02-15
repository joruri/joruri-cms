# encoding: utf-8
require 'nkf'
require 'csv'
class Article::Admin::DocsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  include Sys::Controller::Scaffold::Recognition
  include Sys::Controller::Scaffold::Publication
  helper Article::FormHelper

  include Article::DocsCommon

  def pre_dispatch
    @content = Cms::Content.find(params[:content])
    return error_auth unless @content
    return error_auth unless Core.user.has_priv?(:read, item: @content.concept)
    return redirect_to(request.env['PATH_INFO']) if params[:reset]

    @recognition_type = @content.setting_value(:recognition_type)
  end

  def index
    return index_options if params[:options]
    return user_options if params[:user_options]
    redirect_to article_edit_docs_path
  end

  def index_options
    @items = Article::Doc.where(state: 'public', content_id: @content.id)
    docs_table = @items.table

    if params[:exclude]
      @items = @items.where(docs_table[:name].not_eq(params[:exclude]))
    end
    if params[:title] && !params[:title].blank?
      @items = @items.where(docs_table[:title].matches("%#{params[:title]}%"))
    end
    if params[:id] && !params[:id].blank?
      @items = @items.where(docs_table[:id].eq(params[:id]))
    end

    if params[:group_id] || params[:user_id]
      inners = []
      if params[:group_id] && !params[:group_id].blank?
        groups = Sys::Group.arel_table
        inners << :group
      end
      if params[:user_id] && !params[:user_id].blank?
        users = Sys::User.arel_table
        inners << :user
      end
      @items = @items.joins(:creator => inners)

      @items = @items.where(groups[:id].eq(params[:group_id])) if params[:group_id].present?
      @items = @items.where(users[:id].eq(params[:user_id])) if params[:user_id].present?
    end

    @items = @items.order(published_at: :desc, updated_at: :desc)

    @items = @items.map { |item| [view_context.truncate("[#{item.id}] #{item.title}", length: 50), item.id] }
    render html: view_context.options_for_select([nil] + @items), layout: false
  end

  def download_csv
      csv = CSV.generate do |csv|
      row = []
      row << '記事番号'
      row << "タイトル"
      row << "所属"
      row << "更新日時"
      row << "状態"
      row << "URL"
      row << "分野"
      row << "属性"
      row << "地域"
      row << "新着記事表示"
      row << "記事一覧表示"
      row << "イベントカレンダー表示"
      row << "イベント日付"
      csv << row

      @items.each_with_index do |item, idx|
        row = []
        row << item.id
        row << item.title
        row << item.creator&.group&.name
        row << item.updated_at&.strftime("%Y-%m-%d %H:%M")
        row << item.status.name
        row << item.public_full_uri
        row << item.category_items.collect {|c| c.title }.join('， ')
        row << item.attribute_items.collect {|c| c.title }.join('， ')
        row << item.area_items.collect {|c| c.title }.join('， ')
        row << item.recent_state_text
        row << item.list_state_text
        row << item.event_state_text
        row << ( item.event_date.present? ? item.event_date&.strftime("%Y-%m-%d") : '' )
        csv << row
      end
    end

    filename = "#{@content.name}_#{Time.now.strftime('%Y-%m-%d')}"
    filename = CGI.escape(filename) if request.env['HTTP_USER_AGENT'] =~ /MSIE/
    csv = NKF.nkf('-sW -Lw', csv)
    send_data(csv, type: 'text/csv; charset=Shift_JIS', filename: "#{filename}.csv")
  end


  def user_options
    @parent = Sys::Group.find(params[:group_id])
    render 'user_options', layout: false
  end

  def show
    @item = Article::Doc.find(params[:id])
    if @item.unset_inquiry_email_presence?
      @item.unset_inquiry_email_presence
    else
      @item.reset_inquiry_email_presence
    end
    @item.recognition.type = @recognition_type if @item.recognition

    _show @item
  end

  def new
    @item = Article::Doc.new(content_id: @content.id,
                             state: 'recognize',
                             recent_state: 'visible',
                             list_state: 'visible',
                             event_state: 'hidden',
                             sns_link_state: 'visible')

    state = @content.setting_value(:inquiry_default_state)
    @item.in_inquiry = @item.default_inquiry(
      state: (state.blank? ? 'visible' : state))

    @item.in_recognizer_ids = @content.setting_value(:default_recognizers)
    if @item.unset_inquiry_email_presence?
      @item.unset_inquiry_email_presence
    else
      @item.reset_inquiry_email_presence
    end
    ## add tmp_id
    unless params[:_tmp]
      return redirect_to url_for(action: :new, _tmp: Util::Sequencer.next_id(:tmp, md5: true))
    end
  end

  def create
    @item = Article::Doc.new(docs_params)
    @item.content_id = @content.id
    @item.state      = 'draft'
    @item.state      = 'recognize' if params[:commit_recognize]
    @item.state      = 'public'    if params[:commit_public]
    if @item.unset_inquiry_email_presence?
      @item.unset_inquiry_email_presence
    else
      @item.reset_inquiry_email_presence
    end
    unid = params[:_tmp] || @item.unid

    ## link check
    @checker = Sys::Lib::Form::Checker.new
    if params[:link_check] == '1'
      @checker.check_link @item.body
      return render action: :new
    elsif @item.state =~ /(recognize|public)/
      if @content.setting_value(:auto_link_check) != 'disabled' &&
         params[:link_check] != '0'
        @item.link_checker = @checker
      end
    end

    set_categories(@item)
    _create @item do
      @item.fix_tmp_files(params[:_tmp])
      @item.body = @item.body.gsub(
        article_preview_doc_file_path(parent: unid) + '/', "./")
      @item.save(validate: false) if @item.changed?

      @item = Article::Doc.find(@item.id)
      send_recognition_request_mail(@item) if @item.state == 'recognize'
      publish_by_update(@item) if @item.state == 'public'

      publish_related_pages(@item) if @item.state == 'public'
    end
  end

  def update
    @item = Article::Doc.find(params[:id])

    ## reset related docs
    @item.in_rel_doc_ids = [] if @item.in_rel_doc_ids.present? && docs_params[:in_rel_doc_ids].blank?

    @item.attributes = docs_params
    @item.state      = 'draft'
    @item.state      = 'recognize' if params[:commit_recognize]
    @item.state      = 'public'    if params[:commit_public]
    if @item.unset_inquiry_email_presence?
      @item.unset_inquiry_email_presence
    else
      @item.reset_inquiry_email_presence
    end
    ## convert sys urls
    unid = params[:_tmp] || @item.unid

    @item.body = @item.body.gsub(
      article_preview_doc_file_path(parent: unid) + '/', "./")

    ## link check
    @checker = Sys::Lib::Form::Checker.new
    if params[:link_check] == '1'
      @checker.check_link @item.body
      return render action: :edit
    elsif @item.state =~ /(recognize|public)/
      if @content.setting_value(:auto_link_check) != 'disabled' &&
         params[:link_check] != '0'
        @item.link_checker = @checker
      end
    end

    set_categories(@item)
    _update(@item) do
      send_recognition_request_mail(@item) if @item.state == 'recognize'
      publish_by_update(@item) if @item.state == 'public'
      @item.close unless @item.public?

      publish_related_pages(@item) if @item.state == 'public'
    end
  end

  def destroy
    @item = Article::Doc.find(params[:id])
    set_categories(@item)
    _destroy @item do
      publish_related_pages(@item)
    end
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
        format.html { redirect_to url_for(action: :index) }
        format.xml  { head :ok }
      end
    else
      flash[:notice] = "複製処理に失敗しました。"
      respond_to do |format|
        format.html { redirect_to url_for(action: :show) }
        format.xml  { render xml: item.errors, status: :unprocessable_entity }
      end
    end
  end

  def duplicate_for_replace(item)
    if item.editable? && dupe_item = item.duplicate(:replace)
      flash[:notice] = '複製処理が完了しました。'
      respond_to do |format|
        format.html { redirect_to url_for(action: :index) }
        format.xml  { head :ok }
      end
    else
      flash[:notice] = "複製処理に失敗しました。"
      respond_to do |format|
        format.html { redirect_to url_for(action: :show) }
        format.xml  { render xml: item.errors, status: :unprocessable_entity }
      end
    end
  end

  def publish_ruby(item)
    uri = item.public_uri
    uri = if uri =~ /\?/
            uri.gsub(/\?/, 'index.html.r?')
          else
            "#{uri}index.html.r"
          end
    path = "#{item.public_path}.r"
    item.publish_page(render_public_as_string(uri, site: item.content.site),
                      path: path, uri: uri, dependent: :ruby)
  end

  def publish(item)
    item.public_uri = "#{item.public_uri}?doc_id=#{item.id}"
    set_categories(item)
    _publish(item) do
      publish_ruby(item)
      publish_related_pages(item)
    end
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
    body << "#{Core.user.name}さんより「#{item.title}」についての"
    body << "承認依頼が届きました。\n"
    body << "次の手順により，承認作業を行ってください。\n\n"
    body << "1. PC用記事のプレビューにより文書を確認\n"
    body << "#{item.preview_uri(params: { doc_id: item.id })}\n\n"
    body << "2. 次のリンクから承認を実施\n"
    body << "#{Core.site.admin_uri(path: article_all_doc_path(id: item.id))}\n"

    (users || item.recognizers).each do |user|
      send_mail(
        to: user.email,
        from: Core.user.email,
        subject: "#{item.content.name} 承認依頼メール | #{item.content.site.name}",
        body: body.join)
    end
  end

  def send_recognition_success_mail(item)
    return true unless item.recognition
    return true unless item.recognition.user
    return true if item.recognition.user.email.blank?

    task   = item.find_task_by_name('publish')
    notice = task.blank? ? '' : "直ちに公開する場合は"

    body = []
    body << "「#{item.title}」についての承認が完了しました。\n"
    body << "#{notice}次のURLをクリックして公開処理を行ってください。\n\n"
    body << "#{Core.site.admin_uri(path: article_all_doc_path(id: item.id))}\n\n"
    body << "公開予定日時　#{task.strftime('%Y年%-m月%-d日 %H:%M')}\n" unless task.blank?

    send_mail(
      from: Core.user.email,
      to: item.recognition.user.email,
      subject: "#{item.content.name} 最終承認完了メール | #{item.content.site.name}",
      body: body.join)
  end

  private

  def set_categories(item)
    if oitem = Article::Doc.find_by_id(item.id)
      @old_category_ids = oitem.category_items.inject([]){|ids, category| ids | category.ancestors.map(&:id) }
    else
      @old_category_ids = []

    end

    @new_category_ids = @item.category_items.inject([]){|ids, category| ids | category.ancestors.map(&:id) }
  end

  def docs_params
    area_ids = Article::Area.content_is(@content).pluck(:id).map(&:to_s)

    params.require(:item).permit(
      :title, :language_id, :body, :recent_state, :list_state, :event_state,
      :event_date, :event_close_date, :sns_link_state, :agent_state,
      :mobile_body, :published_at, :in_recognizer_ids,
      in_tags: %w(0 1 2),
      in_rel_doc_ids: [],
      in_maps: [:name, :title, :map_lat, :map_lng, :map_zoom,
                markers: [:name, :lat, :lng]],
      in_category_ids: %w(0 1 2),
      in_attribute_ids: ['0'],
      in_area_ids: ['_'] << area_ids,
      in_inquiry: [:state, :group_id, :charge, :tel, :fax, :email],
      in_tasks: [:publish, :close],
      in_editable_groups: %w(0 1 2),
      in_creator: [:group_id, :user_id])
  end
end
