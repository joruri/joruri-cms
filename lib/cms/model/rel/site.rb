# encoding: utf-8
module Cms::Model::Rel::Site
  extend ActiveSupport::Concern

  included do
    has_one :site, primary_key: 'site_id', foreign_key: 'id',
                   class_name: 'Cms::Site'
  end
end
