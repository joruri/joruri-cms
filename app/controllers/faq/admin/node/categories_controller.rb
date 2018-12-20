# encoding: utf-8
class Faq::Admin::Node::CategoriesController < Cms::Admin::Node::BaseController
  private

  def base_params_item_in_settings
    [:list_count]
  end
end
