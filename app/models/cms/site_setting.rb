# encoding: utf-8
class Cms::SiteSetting < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Auth::Manager
  include Cms::Model::Rel::Site

  validates :site_id, :name, presence: true
end
