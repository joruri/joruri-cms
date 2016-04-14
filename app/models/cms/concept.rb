# encoding: utf-8
class Cms::Concept < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::Creator
  include Sys::Model::Rel::Role
  include Sys::Model::Tree
  include Sys::Model::Base::Page
  include Sys::Model::Auth::Manager

  include StateText

  has_many :children, -> { order(:name) },
           foreign_key: :parent_id,
           class_name: 'Cms::Concept',
           dependent: :destroy

  has_many :layouts, -> { order(:name) },
           foreign_key: :concept_id,
           class_name: 'Cms::Layout',
           dependent: :destroy

  has_many :pieces, -> { order(:name) },
           foreign_key: :concept_id,
           class_name: 'Cms::Piece',
           dependent: :destroy

  has_many :contents,
           foreign_key: :concept_id,
           class_name: 'Cms::Content',
           dependent: :destroy

  has_many :data_files,
           foreign_key: :concept_id,
           class_name: 'Cms::DataFile',
           dependent: :destroy

  has_many :data_file_nodes,
           foreign_key: :concept_id,
           class_name: 'Cms::DataFileNode',
           dependent: :destroy

  validates :site_id, :state, :level_no, :name, presence: true

  def validate
    errors.add :parent_id, :invalid if !id.nil? && id == parent_id
  end

  def targets
    [%w(現在のコンセプトから current), %w(すべてのコンセプトから all)]
  end

  def readable_children
    site = Core.site
    user = Core.user
    rel = self.class.where(state: 'public',
                           site_id: site.id, parent_id: id.to_i)

    unless user.has_auth?(:manager)
      gids = user.group.parents_tree.collect(&:id)
      priv_name = 'read'
      rel = rel.where(
        unid: Sys::ObjectPrivilege.select(:item_unid).where(
          action: priv_name,
          role_id: Sys::UsersRole.select(:role_id).where(
            Sys::UsersRole.arel_table[:user_id].eq(user.id)
            .or(Sys::UsersRole.arel_table[:group_id].eq(gids))
          )
        )
      )
    end

    rel.order(:sort_no)
  end

  def parent
    self.class.find_by(id: parent_id)
  end

  def self.find_by_path(path)
    return nil if path.to_s == ''
    parent_id = 0
    item = nil

    path.split('/').each do |name|
      item = where(parent_id: parent_id, name: name).order(:id).first
      return nil unless item

      parent_id = item.id
    end

    item
  end

  def path
    path = name
    id = parent_id
    lo = 0
    while item = Cms::Concept.find_by(id: id)
      id = item.parent_id
      path = item.name + '/' + path
      lo += 1
      if lo > 100
        path = nil
        break
      end
    end if id > 0
    path
  end

  def make_candidates
    choiced = []
    choices = []
    down    = lambda do |p, i|
      next unless choiced[p.id].nil?
      choiced[p.id] = true

      choices << [('　　' * i) + p.name, p.id]
      c_items = self.class.where(parent_id: p.id)
      c_items = c_items.where(id: id) if id
      c_items.order(:sort_no).each do |c|
        down.call(c, i + 1)
      end
    end

    items = self.class.where(site_id: Core.site.id, level_no: 1)
    items = items.where.not(id: id) if id
    items.order(:sort_no).each { |item| down.call(item, 0) }
    choices
  end

  def candidate_parents
    make_candidates
  end
end
