# encoding: utf-8
module Sys::Model::Base::Config
  extend ActiveSupport::Concern

  included do
    scope :enabled, -> {
      where(state: 'enabled')
    }

    scope :disabled, -> {
      where(state: 'disabled')
    }
  end


  def states
    [%w(有効 enabled), %w(無効 disabled)]
  end

  def enabled?
    state == 'enabled'
  end

  def disabled?
    state == 'disabled'
  end
end
