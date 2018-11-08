# encoding: utf-8
module Sys::Controller::Admin::Auth::Lockout

  ## initialize
  def load_lockout_config
    return true if @loaded_lockout_config
    @lockout_allow_attempt_count = Sys::Setting.value(:lockout_allow_attempt_count, '0').to_i
    @loaded_lockout_config = true
  end

  def lockout_config(key=nil)
    load_lockout_config
    case key
      when :allow_attempt_count
        @lockout_allow_attempt_count
    else
      nil
    end
  end

  def enable_lockout?
    return @enable_lockout if @enable_lockout
    @enable_lockout = lockout_config(:allow_attempt_count) > 0
  end

  def locked_out_notice
    if @failed_logins && @failed_logins.count >= lockout_config(:allow_attempt_count)
      "ログインに#{lockout_config(:allow_attempt_count)}回以上失敗したため、ユーザIDが無効になっています。<br/>管理者にお問合せください。"
    else
      "ユーザID・パスワードを正しく入力してください。"
    end
  end

  def locked_out?(account=nil)
    return false unless enable_lockout?
    return true if failed_logins(account).count >= lockout_config(:allow_attempt_count)
    false
  end

  def failed_logins(account=nil)
    _account = account
    _account ||= current_user.account if current_user
    @failed_logins = Sys::LoginAttempt.where("account = ?", _account).order(:id)
  end

  # override
  def new_login(_account, _password)
    return super(_account, _password) unless enable_lockout?
    return false if locked_out?(_account)

    # login attempt
    _logged_in = super(_account, _password)
    if _logged_in
      Sys::LoginAttempt.delete_all(:account => _account)
    else
      Sys::LoginAttempt.journal(_account, :request => request)
    end
    _logged_in
  end

end
