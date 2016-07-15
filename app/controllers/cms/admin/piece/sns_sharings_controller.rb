# encoding: utf-8
class Cms::Admin::Piece::SnsSharingsController < Cms::Admin::Piece::BaseController
  private

  def base_params
    params.require(:item).permit(
      :concept_id, :name, :state, :title, :view_title,
      in_link_types: [:tweet, :fb_like, :fb_share, :gp_share],
      in_creator: [:group_id, :user_id]
    )
  end
end
