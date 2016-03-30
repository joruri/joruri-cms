# encoding: utf-8
module Sys::Model::Auth::EditableGroup
  extend ActiveSupport::Concern

  included do
    scope :editable, -> {
      return all if Core.user.has_auth?(:manager)

      rel = joins(:creator)
      rel = rel.includes(:editable_group).references(:editable_group)

      creators = Sys::Creator.arel_table
      editable_groups = Sys::EditableGroup.arel_table

      rel = rel.where(creators[:group_id].eq(Core.user.group.id)
        .or(editable_groups[:group_ids].eq(Core.user.group.id.to_s)
          .or(editable_groups[:group_ids].matches("#{Core.user.group.id} %")
            .or(editable_groups[:group_ids].matches("% #{Core.user.group.id} %")
              .or(editable_groups[:group_ids].matches("% #{Core.user.group.id}"))
               )
             )
           )
                     )

      rel
    }
  end

  def creatable?
    return false unless Core.user.has_auth?(:creator)
    # return Core.user.has_priv?(:create, :item => content.concept)
    true
  end

  def editable?
    return true if Core.user.has_auth?(:manager)
    return false unless Core.user.has_auth?(:creator)
    return false unless creator
    return true if creator.group_id == Core.user_group.id
    return false unless editable_group
    editable_group.group_ids =~ /(^| )#{Core.user_group.id}( |$)/
  end

  def deletable?
    editable?
  end
end
