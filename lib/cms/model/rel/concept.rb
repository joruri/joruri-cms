# encoding: utf-8
module Cms::Model::Rel::Concept
  extend ActiveSupport::Concern

  included do
    belongs_to :concept, foreign_key: 'concept_id', class_name: 'Cms::Concept'

    scope :conditions_to_concept, ->(action = :read, _options = {}) {
      rel = all
      concept_ids = []

      my_concepts = Cms::Concept
                    .has_priv(action, user: Core.user)
                    .where(state: 'public')
                    .select(:id)
                    .order(:sort_no)

      for concept in my_concepts
        concept_ids << concept.id.to_s
      end

      rel = where(concept_id: concept_ids) if concept_ids.size > 0
      rel
    }
  end
end
