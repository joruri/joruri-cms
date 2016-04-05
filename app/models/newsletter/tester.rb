# encoding: utf-8
class Newsletter::Tester < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Base::Config
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::Creator
  include Cms::Model::Rel::Content
  include Cms::Model::Auth::Concept

  include StateText
  include AgentStateText

  validates :state, :email, presence: true

  def validate
    maximum = 20
    if self.class.count(conditions: { content_id: content_id }) >= maximum
      errors.add :base, "登録できるメールアドレス は #{maximum}件までです。"
    end
  end

  def agent_states
    [%w(PC用 pc), %w(携帯用 mobile)]
  end

  def mobile?
    agent_state == 'mobile'
  end
end
