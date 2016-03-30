# encoding: utf-8
module Sys::Model::Base::Config
  def states
    [%w(有効 enabled), %w(無効 disabled)]
  end

  def enabled
    self.and :state, 'enabled'
    self
  end

  def disabled
    self.and :state, 'disabled'
    self
  end

  def enabled?
    state == 'enabled'
  end

  def disabled?
    state == 'disabled'
  end
end
