# encoding: utf-8
module Cms::Model::Rel::Site
  def self.included(mod)
    mod.has_one :site, :primary_key => 'site_id', :foreign_key => 'id', :class_name => 'Cms::Site'
  end
  
  def site_is(site)
    self.and :site_id, site.id
  end
end