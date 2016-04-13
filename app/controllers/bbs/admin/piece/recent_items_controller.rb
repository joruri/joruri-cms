# encoding: utf-8
class Bbs::Admin::Piece::RecentItemsController < Cms::Admin::Piece::BaseController
  private

  def base_params_item_in_settings
    [:list_type, :list_count]
  end
end
