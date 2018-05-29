# encoding: utf-8
class Article::Admin::Node::DocsController < Cms::Admin::Node::BaseController
  private

  def base_params_item_in_settings
    [:show_concept_id, :show_layout_id]
  end
end
