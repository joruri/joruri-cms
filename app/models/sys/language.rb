# encoding: utf-8
class Sys::Language < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Base::Config
  include Sys::Model::Auth::Manager

  include StateText

  validates :state, :name, :title, presence: true

  def states
    [%w(有効 enabled), %w(無効 disabled)]
  end
end
