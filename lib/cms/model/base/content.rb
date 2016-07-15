# encoding: utf-8
module Cms::Model::Base::Content
  extend ActiveSupport::Concern

  included do
    belongs_to :status, foreign_key: :state, class_name: 'Sys::Base::Status'
  end

  def states
    [%w(公開 public), %w(非公開 closed)]
  end

  def module_name(option = nil)
    name = Cms::Lib::Modules.model_name(:content, model)
    return name.to_s.gsub(/.*\//, '') if option == :short
    name
  end

  def public_path
    id_dir = Util::String::CheckDigit.check(format('%07d', id)).gsub(/(.*)(..)(..)(..)$/, '\1/\2/\3/\4/\1\2\3\4')
    "#{site.public_path}/_contents/#{id_dir}"
  end

  def public_uri(class_name)
    node = Cms::Node.where(content_id: id, model: class_name.to_s)
                    .order(:id).first
    return nil unless node
    node.public_uri
  end

  def admin_uri
    controller = model.underscore.pluralize.gsub(/^(.*?\/)/, "\\1c#{concept_id}/#{id}/")
    "#{Joruri.admin_uri}/#{controller}"
  end

  def admin_content_uri
    controller = model.to_s.underscore.pluralize.gsub(/^(.*?)\/.*/, "\\1/c#{concept_id}/content_base")
    "#{Joruri.admin_uri}/#{controller}/#{id}"
  end
end
