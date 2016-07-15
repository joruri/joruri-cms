# encoding: utf-8
class Cms::Admin::Piece::FreesController < Cms::Admin::Piece::BaseController
  private

  def base_params_item
    [:body, :concept_id, :name, :state, :title, :view_title]
  end
end
