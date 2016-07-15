# encoding: utf-8
class Cms::LinkCheck < ActiveRecord::Base
  include Sys::Model::Base

  validates :link_uri, presence: true
end
