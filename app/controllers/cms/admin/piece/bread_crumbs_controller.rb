# encoding: utf-8
class Cms::Admin::Piece::BreadCrumbsController < Cms::Admin::Piece::BaseController
  private

  def base_params_item_in_settings
    [:top_label]
  end
end
