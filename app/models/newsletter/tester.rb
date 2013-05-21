# encoding: utf-8
class Newsletter::Tester < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Base::Config
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::Creator
  include Cms::Model::Rel::Content
  include Cms::Model::Auth::Concept

  belongs_to :status, :foreign_key => :state, :class_name => 'Sys::Base::Status'

  validates_presence_of :state, :email

  def validate
    maximum = 20
    if self.class.count(:conditions => {:content_id => content_id}) >= maximum
      errors.add :base, "登録できるメールアドレス は #{maximum}件までです。"
    end
  end

  def agent_states
    [['PC用','pc'], ['携帯用','mobile']]
  end

  def agent_status
    agent_states.each do |name, id|
      return Sys::Base::Status.new(:id => id, :name => name) if agent_state.to_s == id
    end
    nil
  end

  def mobile?
    agent_state == 'mobile'
  end
end