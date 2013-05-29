# encoding: utf-8
class Cms::Admin::Inline::DataFileNodesController < Cms::Admin::Data::FileNodesController
  def pre_dispatch
    simple_layout
    super
  end
end
