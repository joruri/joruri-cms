# encoding: utf-8
class Calendar::Admin::Node::EventsController < Cms::Admin::Node::BaseController
  private

  def base_params_item_in_settings
    [:list_type]
  end
end
