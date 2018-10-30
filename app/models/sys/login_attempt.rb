# encoding: utf-8
class Sys::LoginAttempt < ActiveRecord::Base
  include Sys::Model::Base

  belongs_to :status,     :foreign_key => :state, :class_name => 'Sys::Base::Status'
  belongs_to :user,  :foreign_key => :account, :primary_key => :account, :class_name => 'Sys::User'
  has_many   :login_attempts,  :foreign_key => :account,:primary_key => :account, :class_name => 'Sys::LoginAttempt'

  def states
    [['失敗','failed']]
  end

  def lock_out_status
    return @lock_out_status if @locked_out === true || @locked_out === false
    @lockout_allow_attempt_count = Sys::Setting.value(:lockout_allow_attempt_count, '0').to_i
    @locked_out = login_attempts.count >= @lockout_allow_attempt_count
    @lock_out_status = @locked_out ? 'ロックアウト' : '';
  end

  scope :search, -> (params) {
    rel = all

    attempts = arel_table

    params.each do |n, v|
      next if v.to_s == ''

      case n
      when 's_state'
        rel = rel.where(state: v)
      when 's_account'
        rel = rel.where(account: v)
      when 's_ipaddr'
        rel = rel.where(attempts[:ipaddr].matches("%#{v.gsub(/([%_])/, '\\\\\1')}%"))
      when 's_account_by_id'
        if att = self.find(v)
          rel = rel.where(account: att.account)
        else
          rel = rel.where(0, 1)
        end
      end
    end if params.size != 0

    rel
  }


  def self.journal(_account, options={})
    _ipaddr     = nil
    _user_agent = nil

    if req = options[:request]
      _ipaddr     = req.env['REMOTE_ADDR'] == req.env['HTTP_VIA'] ? (req.env['HTTP_X_FORWARD_FOR'] || req.env['REMOTE_ADDR']) : req.env['REMOTE_ADDR']
      _user_agent = req.env["HTTP_USER_AGENT"]
    end

    self.create(
      :state => 'failed',
      :account => _account,
      :ipaddr => _ipaddr,
      :user_agent => _user_agent)
  end

end
