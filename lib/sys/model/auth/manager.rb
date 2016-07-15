# encoding: utf-8
module Sys::Model::Auth::Manager
  extend ActiveSupport::Concern

  included do
    scope :readable, -> {
      return none unless Core.user.has_auth?(:manager)
      all
    }

    scope :editable, -> {
      return none unless Core.user.has_auth?(:manager)
      all
    }
  end

  def creatable?
    Core.user.has_auth?(:manager)
  end

  def readable?
    Core.user.has_auth?(:manager)
  end

  def editable?
    Core.user.has_auth?(:manager)
  end

  def deletable?
    Core.user.has_auth?(:manager)
  end
end
