# encoding: utf-8
class Cms::Inquiry < ActiveRecord::Base
  include Sys::Model::Base

  belongs_to :group, foreign_key: :group_id, class_name: 'Sys::Group'

  before_save :set_group

  def visible?
    state == 'visible'
  end

  def set_group
    self.group_id = Core.user_group.id unless group_id
  end
end
