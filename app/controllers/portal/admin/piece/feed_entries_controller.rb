# encoding: utf-8
class Portal::Admin::Piece::FeedEntriesController < Cms::Admin::Piece::BaseController
  private

  def base_params_item_in_settings
    [:category]
  end
end
