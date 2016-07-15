# encoding: utf-8
class Cms::Admin::Content::RewriteController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:manager)

    @file = Core.site.rewrite_config_path
  end

  def show
    @current_conf = ::File.exist?(@file) ? ::File.new(@file).read : "ファイルが見つかりません"
    @update_conf  = make_conf
  end

  def update
    unless params[:update].blank?
      flash[:notice] = if ::File.write(@file, make_conf)
                         "ファイルを更新しました。 （反映にはWebサーバーの再起動が必要です。）"
                       else
                         "ファイルの更新に失敗しました。"
                       end
    end

    redirect_to url_for(action: :show)
  end

  protected

  def make_conf
    cond = { site_id: Core.site.id }
    conf = []

    Cms::Content.where(cond).order(:id).each do |item|
      name = item.model.to_s.gsub(/^(.*?::)/, '\\1Content::')
      begin
        eval(name)
        model = eval(name)
      rescue
        model = nil
      end
      next unless model

      content = model.find_by(id: item.id)
      next unless content

      conf += content.rewrite_configs
    end

    conf.join("\n")
  end
end
