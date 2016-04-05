# encoding: utf-8
module Cms::Model::Base::Node
  extend ActiveSupport::Concern

  included do
    belongs_to :status, foreign_key: :state, class_name: 'Sys::Base::Status'

    scope :published, -> {
        where(state: 'public')
    }
  end

  def states
    [%w(公開 public), %w(非公開 closed)]
  end

  def public?
    state == 'public' && !published_at.blank?
  end

  def content_name
    return content.name if content
    Cms::Lib::Modules.module_name(:cms)
  end

  def module_name(option = nil)
    name = Cms::Lib::Modules.model_name(:node, model)
    return name.to_s.gsub(/^(.*?\/).*?\//, '\\1') if option == :short
    name
  end

  def model_type
    return nil unless mod = Cms::Lib::Modules.find(:node, model)
    mod.type
  end

  def admin_uri
    controller = model.underscore.pluralize.gsub(/^(.*?\/)/, "\\1c#{concept_id}/#{parent_id}/node_")
    "#{Joruri.admin_uri}/#{controller}/#{id}"
  end

  def edit_admin_uri
    "#{admin_uri}/edit"
  end

  def routes
    loop      = 0
    exists    = [id]
    routes    = [self]
    parent_id = route_id
    while (current = self.class.find_by(id: parent_id))
      break if exists.index(current.id)
      exists << current.id

      routes.unshift(current)
      parent_id = current.route_id
      break if parent_id == 0
      break if loop > 20
      loop += 1
    end if id != parent_id
    [routes]
  end

  def bread_crumbs(node = nil)
    crumbs = []
    node ||= self
    node.routes.each do |r|
      crumbs << r.collect { |i| [i.title, i.public_uri] }
    end
    Cms::Lib::BreadCrumbs.new(crumbs)
  end

  def locale(name)
    _model = self.class.to_s.underscore.gsub(/\/model/, '')
    label = I18n.t name, scope: [:activerecord, :attributes, _model]
    if label =~ /^translation missing:/
      label = I18n.t name, scope: [:activerecord, :attributes, 'cms/node']
      return label =~ /^translation missing:/ ? name.to_s.humanize : label
    end
    label
  end
end
