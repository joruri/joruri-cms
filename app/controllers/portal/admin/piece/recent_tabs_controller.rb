# encoding: utf-8
class Portal::Admin::Piece::RecentTabsController < Cms::Admin::Piece::BaseController
  private

  def base_params_item_in_settings
    [:list_count, :more_label]
  end
end
