# encoding: utf-8
module Cms::Model::Base::Page
  extend ActiveSupport::Concern

  included do
    scope :published, -> {
      where(state: 'public')
    }

    scope :public_or_preview, -> {
      return all if Core.mode == 'preview'
      published
    }
  end

  def states
    [%w(公開 public), %w(非公開 closed)]
  end

  def public?
    state == 'public' && !published_at.blank?
  end
end
