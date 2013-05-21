# encoding: utf-8
class Sys::Language < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Base::Config
  include Sys::Model::Auth::Manager
  
  belongs_to :status,  :foreign_key => :state,      :class_name => 'Sys::Base::Status'
  
  validates_presence_of :state, :name, :title
  
  def states
    [['有効','enabled'],['無効','disabled']]
  end
end
