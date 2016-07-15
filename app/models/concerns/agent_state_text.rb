module AgentStateText
  extend ActiveSupport::Concern

  class Responder
    def self.state_text(state)
      state = '' if state.nil?
      case state
      when '' then '全てに表示'
      when 'pc' then 'PCのみ表示'
      when 'mobile' then '携帯のみ表示'
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

  def agent_status
    Responder.new(self, :agent_state)
  end

  def agent_state_text
    Responder.state_text(agent_state)
  end
end
