# encoding: utf-8
module Cms::Model::Rel::Concept
  def self.included(mod)
    mod.belongs_to :concept, :foreign_key => 'concept_id', :class_name => 'Cms::Concept'
  end

  def conditions_to_concept(action = :read, options = {})
    concept_ids = []

    concept = Cms::Concept.new
    concept.has_priv(action, :user => Core.user)
    my_concepts = concept.find(:all, :select => "#{Cms::Concept.table_name}.id" , :conditions => {:state => 'public'}, :order => :sort_no )

    for concept in my_concepts
      concept_ids << concept.id.to_s
    end
    if concept_ids.size > 0
      self.and :concept_id, concept_ids
    end
  end
end