# encoding: utf-8
class Sys::Message < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Base::Page
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::Creator
  include Sys::Model::Auth::Manager
  
  belongs_to :status,  :foreign_key => :state,      :class_name => 'Sys::Base::Status'
  
  validates_presence_of :state, :published_at, :title, :body
end
