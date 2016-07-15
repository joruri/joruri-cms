# encoding: utf-8
module Sys::Model::Auth::Free
  extend ActiveSupport::Concern

  included do
    scope :readable, -> {
      all
    }

    scope :editable, -> {
      all
    }
  end

  def creatable?
    true
  end

  def readable?
    true
  end

  def editable?
    true
  end

  def deletable?
    true
  end
end
