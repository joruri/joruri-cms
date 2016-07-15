# encoding: utf-8
class Sys::Maintenance < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Base::Page
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::Creator
  include Sys::Model::Auth::Manager

  include StateText

  validates :state, :published_at, :title, :body, presence: true
end
