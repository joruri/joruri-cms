# encoding: utf-8
class Article::Admin::Node::EventDocsController < Cms::Admin::Node::BaseController
  private

  def base_params_item_in_settings
    [:list_type]
  end
end
