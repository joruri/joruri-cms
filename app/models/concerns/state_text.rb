module StateText
  extend ActiveSupport::Concern

  class Responder
    def self.state_text(state)
      case state
      when 'enabled' then '有効'
      when 'disabled' then '無効'
      when 'visible' then '表示'
      when 'hidden' then '非表示'
      when 'draft' then '下書き'
      when 'recognize' then '承認待ち'
      when 'approvable' then '承認待ち'
      when 'recognized' then '公開待ち'
      when 'approved' then '公開待ち'
      when 'prepared' then '公開'
      when 'public' then '公開中'
      when 'closed' then '非公開'
      when 'completed' then '完了'
      when 'archived' then '履歴'
      when 'synced' then '同期済'
      when 'failed'; return '失敗'
      else ''
      end
    end

    def initialize(stateable, attribute_name = :state)
      @stateable = stateable
      @attribute_name = attribute_name
    end

    def name
      self.class.state_text(@stateable.send(@attribute_name))
    end
  end

  def status
    Responder.new(self)
  end

  def web_status
    Responder.new(self, :web_state)
  end

  def portal_group_status
    Responder.new(self, :portal_group_state)
  end

  def recent_status
    Responder.new(self, :recent_states)
  end

  def list_status
    Responder.new(self, :list_states)
  end

  def event_status
    Responder.new(self, :event_states)
  end

  def sns_link_status
    Responder.new(self, :sns_link_states)
  end

  def state_text
    Responder.state_text(state)
  end

  def web_state_text
    Responder.state_text(web_state)
  end

  def portal_group_state_text
    Responder.state_text(portal_group_state)
  end

  def recent_state_text
    Responder.state_text(recent_state)
  end

  def list_state_text
    Responder.state_text(list_state)
  end

  def event_state_text
    Responder.state_text(event_state)
  end

  def sns_link_state_text
    Responder.state_text(sns_link_state)
  end
end
