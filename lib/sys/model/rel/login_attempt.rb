# encoding: utf-8
module Sys::Model::Rel::LoginAttempt
  extend ActiveSupport::Concern

  included do
    has_many :login_attempts, foreign_key: 'account', class_name: 'Sys::LoginAttempt',
                     primary_key: 'account', dependent: :destroy
  end

  #def self.included(mod)
  #  mod.has_many   :login_attempts,  :foreign_key => :account,
  #   :primary_key => :account, :class_name => 'Sys::LoginAttempt', :order => :id, :dependent => :destroy
  #end

  def locked_out?
    return @locked_out if @locked_out === true || @locked_out === false
    @lockout_allow_attempt_count = Sys::Setting.value(:lockout_allow_attempt_count, '0').to_i
    @locked_out = login_attempts.count >= @lockout_allow_attempt_count
  end

end
