# encoding: utf-8
class Cms::Admin::Content::RewriteController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  
  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:manager)
    
    @file = Core.site.rewrite_config_path
  end
  
  def show
    @current_conf = ::File.exists?(@file) ? ::File.new(@file).read : "ファイルが見つかりません"
    @update_conf  = make_conf
  end

  def update
    if !params[:update].blank?
      if ::File.write(@file, make_conf)
        flash[:notice] = "ファイルを更新しました。 （反映にはWebサーバの再起動が必要です。）"
      else
        flash[:notice] = "ファイルの更新に失敗しました。"
      end
    end
    
    redirect_to url_for(:action => :show)
  end
  
protected
  def make_conf
    cond = { :site_id => Core.site.id }
    conf = []
    
    Cms::Content.find(:all, :conditions => cond, :order => :id).each do |item|
      name = item.model.to_s.gsub(/^(.*?::)/, '\\1Content::')
      begin
        eval(name)
        model = eval(name)
      rescue
        model = nil
      end
      next unless model
      
      content = model.find_by_id(item.id)
      next unless content
      
      conf += content.rewrite_configs
    end
    
    return conf.join("\n")
  end
end
