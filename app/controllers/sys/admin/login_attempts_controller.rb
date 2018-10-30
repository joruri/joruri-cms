# encoding: utf-8
class Sys::Admin::LoginAttemptsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:manager)
    return redirect_to("#{request.env['PATH_INFO']}?group_by=#{params[:group_by]}") if params[:reset]
  end

  def index
    item = Sys::LoginAttempt.search(params)
    return destroy_items(item) if !params[:destroy].blank?

    item = item.paginate(page: params[:page], per_page: params[:limit])

    if params[:group_by] == 'account'
      item.order params[:sort], "cnt DESC, created_at DESC"
      @items = item.select("#{Sys::LoginAttempt.table_name}.*, MAX(created_at) AS latest_created_at, COUNT(*) AS cnt").group("account")
    else
      item.order params[:sort], "created_at DESC"
      @items = item
    end
    _index @items
  end

  def show
    @item = Sys::LoginAttempt.find(params[:id])
    if @user = @item.user
      @login_attempts = @user.login_attempts.order(:id)
    else
      @user = Sys::User.new
      @login_attempts = Sys::LoginAttempt.where("account = ?", @item.account).order(:id)
    end

    _show @item
  end

  def new
    return error_auth
  end

  def create
    return error_auth
  end

  def update
    return error_auth
  end

  def destroy
    return error_auth
  end

protected

  def destroy_items(item)
    num = item.delete_all

    flash[:notice] = lockout_config(:allow_attempt_count) <= num ? "ロックアウト解除処理が完了しました。" : "失敗履歴の削除処理が完了しました。";
    redirect_to url_for(:action => :index, :group_by => params[:group_by])
  end
end
