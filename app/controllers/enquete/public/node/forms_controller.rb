# encoding: utf-8
class Enquete::Public::Node::FormsController < Cms::Controller::Public::Base
  include Article::Controller::Feed
  include SimpleCaptcha::ControllerHelpers

  def pre_dispatch
    @content = Page.current_node.content
    return http_error(404) unless @content
    @required_symbol   = @content.setting_value(:required_symbol, "※")
    @required_symbol   = "" if @required_symbol == '_blank'
    @use_captcha = @content.setting_value(:use_captcha) == '1'
    @auto_add_attr_title = @content.setting_value(:auto_add_attr_title) == "1"
  end

  def index
    @items = Enquete::Form
             .published
             .where(content_id: @content.id)
             .order(:sort_no, id: :desc)
             .paginate(page: params[:page],
                       per_page: (request.mobile? ? 10 : 20))
  end

  def show
    @item = Enquete::Form
            .published
            .where(content_id: @content.id)
            .where(id: params[:form])
            .first
    return http_error(404) unless @item

    @form = form(@item)

    ## post
    @form.submit_values = params[:item]
    return false unless request.post?

    ## edit
    return false if params[:edit]

    ## validate
    @form.valid?
    if @use_captcha
      @item.captcha     = params[:item][:captcha]
      @item.captcha_key = params[:item][:captcha_key]
      unless @item.valid_with_captcha?
        @form.errors.add :base, @item.errors.to_a[0]
      end
    end
    return false if @form.errors.size > 0

    ## confirm
    if params[:confirm].blank?
      @confirm = true
      @form.freeze
      return false
    end

    ## save
    client = {
      ipaddr: request.remote_addr,
      user_agent: request.user_agent
    }
    unless answer = @item.save_answer(@form.values(:string), client)
      render text: "送信に失敗しました。"
      return false
    end
    @item.remove_captcha_key if @use_captcha

    ## send mail to admin
    begin
      send_answer_mail(@item, answer)
    rescue => e
      error_log("メール送信失敗 #{e}")
    end

    ## send mail to answer
    answer_email = nil
    answer.columns.each do |col|
      next unless col.form_column.name =~ /^(メールアドレス|Email|E-mail)/i
      unless col.value.blank?
        answer_email = col.value
        break
      end
    end

    begin
      if @content.setting_value(:auto_reply) == 'send'
        send_answer_mail(@item, answer, answer_email) unless answer_email.blank?
      end
    rescue => e
      error_log("メール送信失敗 #{e}")
    end

    redirect_to "#{Page.current_node.public_uri}#{@item.id}/sent.html"
  end

  def sent
    @item = Enquete::Form
            .published
            .where(content_id: @content.id)
            .where(id: params[:form])
            .first
  end

  protected

  def form(item)
    form = Sys::Lib::Form::Builder.new(:item, template: view_context)
    item.public_columns.each do |col|
      col_opts = if @auto_add_attr_title
        _col_name = col.name.to_s.gsub(/：|:|\(.*?\)/, '')
        _action = if ['select', 'radio_button', 'check_box'].include?(col.column_type)
          _col_name =~ /[\?|？|。]$/ ? 'の回答を選択' : 'の選択';
        else
          _col_name =~ /[\?|？|。]$/ ? 'の回答を入力' : 'の入力';
        end
        _opts = col.element_options
        _opts[:title] = "#{_col_name}#{_action}"
        _opts
      else
        col.element_options
      end
      col_opts[:format] = col.field_format

      if 'text_area' == col.column_type
        col_opts[:rows] = 2
        col_opts[:cols] = 20
      end
      if 'attachment' == col.column_type
        col_opts[:max_length] = col.form_file_max_size || 1
        col_opts[:valid_ext]  = col.form_file_extension
      end
      form.add_element(col.column_type, col.element_name, col.name, col_opts)
    end
    form
  end

  def send_answer_mail(item, answer, answer_email = nil)
    mail_fr = @content.setting_value(:from_email)
    if mail_fr.blank?
      mail_fr = 'webmaster@' + Page.site.full_uri.gsub(/^.*?\/\/(.*?)(:|\/).*/, '\\1')
      mail_fr = mail_fr.gsub(/www\./, '')
    end

    mail_to = answer_email || item.content.setting_value(:email)
    return false if mail_to.blank?

    name    = answer_email.blank? ? '投稿' : '自動返信'
    subject = "#{item.name} #{name} | #{item.content.site.name}"

    upper_text = item.content.setting_value(:upper_reply_text).to_s
    lower_text = item.content.setting_value(:lower_reply_text).to_s

    message = ''
    message += upper_text + "\n" unless upper_text.blank?

    message += "■フォーム名\n"
    message += "#{item.name}\n\n"
    message += "■回答日時\n"
    message += "#{answer.created_at.strftime('%Y-%m-%d %H:%M')}\n\n"

    if answer_email.blank?
      message += "■IPアドレス\n"
      message += "#{answer.ipaddr}\n\n"
      message += "■ユーザーエージェント\n"
      message += "#{answer.user_agent}\n\n"
    end

    #answer.columns.each do |col|
    #  message += "■#{col.form_column.name}\n"
    #  message += "#{col.value}\n\n"
    #end

    item.public_columns.each do |col|
      message += "■#{col.name}\n"
      answer_body = answer.columns.detect { |a| a.column_id == col.id }&.value
      message += "#{answer_body}\n\n"
    end

    message += lower_text unless lower_text.blank?

    send_mail(from: mail_fr,
              to: mail_to,
              subject: subject,
              body: message)
  end
end
