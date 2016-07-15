# encoding: utf-8
module Sys::Model::Auth::Designer
  extend ActiveSupport::Concern

  included do
    scope :readable, -> {
      return none unless Core.user.has_auth?(:designer)
      all
    }

    scope :editable, -> {
      return none unless Core.user.has_auth?(:designer)
      all
    }
  end

  def creatable?
    Core.user.has_auth?(:designer)
  end

  def readable?
    Core.user.has_auth?(:designer)
  end

  def editable?
    Core.user.has_auth?(:designer)
  end

  def deletable?
    Core.user.has_auth?(:designer)
  end
end
