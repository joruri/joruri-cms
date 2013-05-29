# encoding: utf-8
class Cms::Admin::Inline::DataFilesController < Cms::Admin::Data::FilesController
  def pre_dispatch
    simple_layout
    super
  end
end
